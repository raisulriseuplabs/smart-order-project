<?php

namespace App\Services;

use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use InvalidArgumentException;
use RuntimeException;
use Throwable;

class FtpBrowser
{
    public function credentialsConfigured(): bool
    {
        return filled(config('filesystems.disks.ftp.host'))
            && filled(config('filesystems.disks.ftp.username'));
    }

    public function disconnect(): void
    {
        Storage::forgetDisk('ftp');
    }

    public function ping(): void
    {
        $this->disk()->directories('');
    }

    /**
     * @return array{path: string, entries: array<int, array<string, mixed>>}
     */
    public function list(string $path): array
    {
        $path = $this->normalize($path);
        $disk = $this->disk();

        if ($path !== '' && $disk->fileExists($path)) {
            throw new InvalidArgumentException('Choose a folder to browse.');
        }

        $entries = [
            ...array_map(fn (string $item) => $this->entry($disk, $item, 'directory'), $disk->directories($path)),
            ...array_map(fn (string $item) => $this->entry($disk, $item, 'file'), $disk->files($path)),
        ];

        usort($entries, function (array $left, array $right): int {
            if ($left['type'] !== $right['type']) {
                return $left['type'] === 'directory' ? -1 : 1;
            }

            return strnatcasecmp($left['name'], $right['name']);
        });

        return [
            'path' => $path,
            'entries' => $entries,
        ];
    }

    /**
     * @return array{path: string, content: string, size: int}
     */
    public function read(string $path): array
    {
        $path = $this->normalize($path);
        $disk = $this->disk();
        $this->assertFile($disk, $path);

        $size = $disk->size($path);

        if ($size > $this->editLimit()) {
            throw new RuntimeException('This file is too large to edit here. Download it instead.');
        }

        $content = $disk->get($path);

        if ($this->looksBinary($content)) {
            throw new RuntimeException('This file looks binary. Download it instead of editing it.');
        }

        return [
            'path' => $path,
            'content' => $content,
            'size' => $size,
        ];
    }

    public function write(string $path, string $content): void
    {
        $path = $this->normalize($path);

        if ($path === '') {
            throw new InvalidArgumentException('Choose a file to save.');
        }

        if (strlen($content) > $this->editLimit()) {
            throw new RuntimeException('That text is too large to save from the editor.');
        }

        if ($this->looksBinary($content)) {
            throw new RuntimeException('The editor can only save text.');
        }

        $disk = $this->disk();

        if ($disk->directoryExists($path)) {
            throw new RuntimeException('A folder with that name already exists.');
        }

        $disk->put($path, $content);
    }

    public function makeDirectory(string $directory, string $name): string
    {
        $path = $this->join($directory, $this->singleName($name));
        $disk = $this->disk();

        if ($disk->fileExists($path) || $disk->directoryExists($path)) {
            throw new RuntimeException('Something with that name already exists.');
        }

        $disk->makeDirectory($path);

        return $path;
    }

    public function makeFile(string $directory, string $name, string $content = ''): string
    {
        $path = $this->join($directory, $this->singleName($name));
        $disk = $this->disk();

        if ($disk->fileExists($path) || $disk->directoryExists($path)) {
            throw new RuntimeException('Something with that name already exists.');
        }

        $this->write($path, $content);

        return $path;
    }

    public function rename(string $path, string $name): string
    {
        $path = $this->normalize($path);
        $name = $this->singleName($name);

        if ($path === '') {
            throw new InvalidArgumentException('The drive root cannot be renamed.');
        }

        $target = $this->join($this->parentDirectory($path), $name);

        if ($target === $path) {
            return $path;
        }

        $disk = $this->disk();

        if (! $disk->fileExists($path) && ! $disk->directoryExists($path)) {
            throw new RuntimeException('That item was not found.');
        }

        if ($disk->fileExists($target) || $disk->directoryExists($target)) {
            throw new RuntimeException('Something with that name already exists.');
        }

        $disk->move($path, $target);

        return $target;
    }

    public function delete(string $path, string $type): void
    {
        $path = $this->normalize($path);

        if ($path === '') {
            throw new InvalidArgumentException('The drive root cannot be deleted.');
        }

        $disk = $this->disk();

        if ($type === 'directory') {
            if (! $disk->directoryExists($path)) {
                throw new RuntimeException('That folder was not found.');
            }

            $disk->deleteDirectory($path);

            return;
        }

        if (! $disk->fileExists($path)) {
            throw new RuntimeException('That file was not found.');
        }

        $disk->delete($path);
    }

    public function storeUploadedFile(string $directory, UploadedFile $file, string $relativePath): string
    {
        $target = $this->join($directory, $relativePath);
        $disk = $this->disk();

        if ($disk->directoryExists($target)) {
            throw new RuntimeException('A folder already uses the name '.$target.'.');
        }

        $parent = $this->parentDirectory($target);

        if ($parent !== '' && ! $disk->directoryExists($parent)) {
            $disk->makeDirectory($parent);
        }

        $stream = fopen($file->getRealPath(), 'rb');

        if ($stream === false) {
            throw new RuntimeException('The uploaded file could not be read.');
        }

        try {
            $disk->writeStream($target, $stream);
        } finally {
            if (is_resource($stream)) {
                fclose($stream);
            }
        }

        return $target;
    }

    public function download(string $path): mixed
    {
        $path = $this->normalize($path);
        $disk = $this->disk();
        $this->assertFile($disk, $path);

        return $disk->download($path, basename($path));
    }

    public function normalize(?string $path): string
    {
        $path = str_replace('\\', '/', (string) $path);
        $segments = [];

        foreach (explode('/', $path) as $segment) {
            if ($segment === '' || $segment === '.') {
                continue;
            }

            if ($segment === '..' || preg_match('/[\x00-\x1F\x7F]/', $segment)) {
                throw new InvalidArgumentException('That path is not allowed.');
            }

            $segments[] = $segment;
        }

        $normalized = implode('/', $segments);

        if (strlen($normalized) > 1000) {
            throw new InvalidArgumentException('That path is too long.');
        }

        return $normalized;
    }

    public function singleName(string $name): string
    {
        $name = trim($name);

        if (
            $name === ''
            || $name === '.'
            || $name === '..'
            || str_contains($name, '/')
            || str_contains($name, '\\')
            || preg_match('/[\x00-\x1F\x7F]/', $name)
        ) {
            throw new InvalidArgumentException('Use a name without slashes.');
        }

        return $name;
    }

    public function join(string $directory, string $relative): string
    {
        $directory = $this->normalize($directory);
        $relative = $this->normalize($relative);

        if ($relative === '') {
            throw new InvalidArgumentException('A name is required.');
        }

        return $directory === '' ? $relative : $directory.'/'.$relative;
    }

    public function parentDirectory(string $path): string
    {
        $path = $this->normalize($path);
        $parent = dirname(str_replace('\\', '/', $path));

        if ($parent === '.' || $parent === DIRECTORY_SEPARATOR) {
            return '';
        }

        return $this->normalize($parent);
    }

    public function editLimit(): int
    {
        return 512 * 1024;
    }

    private function disk(): Filesystem
    {
        return Storage::disk('ftp');
    }

    /**
     * @return array{name: string, path: string, type: string, size: int|null, modified: int|null}
     */
    private function entry(Filesystem $disk, string $path, string $type): array
    {
        return [
            'name' => basename($path),
            'path' => $path,
            'type' => $type,
            'size' => $type === 'file' ? $this->metadata($disk, $path, 'size') : null,
            'modified' => $this->metadata($disk, $path, 'lastModified'),
        ];
    }

    private function metadata(Filesystem $disk, string $path, string $method): mixed
    {
        try {
            return $disk->{$method}($path);
        } catch (Throwable) {
            return null;
        }
    }

    private function assertFile(Filesystem $disk, string $path): void
    {
        if ($path === '' || $disk->directoryExists($path) || ! $disk->fileExists($path)) {
            throw new InvalidArgumentException('Choose a file.');
        }
    }

    private function looksBinary(string $contents): bool
    {
        return str_contains($contents, "\0");
    }
}
