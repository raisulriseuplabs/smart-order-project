<?php

namespace App\Http\Controllers;

use App\Services\FtpBrowser;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;
use RuntimeException;
use Throwable;

class FtpBrowserController extends Controller
{
    public function status(FtpBrowser $ftp): JsonResponse
    {
        return response()->json($this->publicState($ftp));
    }

    public function connect(FtpBrowser $ftp): JsonResponse
    {
        if (! $ftp->credentialsConfigured()) {
            return response()->json([
                'message' => 'Add FTP_HOST, FTP_USERNAME, and FTP_PASSWORD to the .env file, then reload this page.',
            ], 422);
        }

        try {
            $ftp->ping();
        } catch (Throwable $exception) {
            $ftp->disconnect();

            return response()->json([
                'message' => $this->safeMessage($exception),
            ], 502);
        }

        session(['ftp.connected' => true]);

        return response()->json($this->publicState($ftp));
    }

    public function disconnect(FtpBrowser $ftp): JsonResponse
    {
        session()->forget('ftp.connected');
        $ftp->disconnect();

        return response()->json($this->publicState($ftp));
    }

    public function list(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['nullable', 'string', 'max:1000'],
        ]);

        return $this->attempt(fn () => response()->json($ftp->list($data['path'] ?? '')));
    }

    public function read(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
        ]);

        return $this->attempt(fn () => response()->json($ftp->read($data['path'])));
    }

    public function download(Request $request, FtpBrowser $ftp): mixed
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
        ]);

        return $this->attempt(fn () => $ftp->download($data['path']));
    }

    public function upload(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $postMax = $this->iniToBytes((string) ini_get('post_max_size'));
        $contentLength = (int) $request->server('CONTENT_LENGTH');

        if ($postMax > 0 && $postMax < PHP_INT_MAX && $contentLength > $postMax) {
            return response()->json([
                'message' => 'That upload is larger than the server allows.',
            ], 413);
        }

        $maxKilobytes = max(1, (int) floor($this->maxUploadBytes() / 1024));

        $data = $request->validate([
            'directory' => ['nullable', 'string', 'max:1000'],
            'files' => ['required', 'array', 'min:1', 'max:40'],
            'files.*' => ['file', 'max:'.$maxKilobytes],
            'paths' => ['nullable', 'array'],
            'paths.*' => ['nullable', 'string', 'max:1000'],
        ]);

        return $this->attempt(function () use ($data, $ftp) {
            $uploaded = 0;

            foreach ($data['files'] as $index => $file) {
                $relative = $data['paths'][$index] ?? $file->getClientOriginalName();
                $ftp->storeUploadedFile($data['directory'] ?? '', $file, (string) $relative);
                $uploaded++;
            }

            return response()->json([
                'uploaded' => $uploaded,
            ]);
        });
    }

    public function makeDirectory(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'directory' => ['nullable', 'string', 'max:1000'],
            'name' => ['required', 'string', 'max:255'],
        ]);

        return $this->attempt(function () use ($data, $ftp) {
            $path = $ftp->makeDirectory($data['directory'] ?? '', $data['name']);

            return response()->json(['path' => $path]);
        });
    }

    public function makeFile(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'directory' => ['nullable', 'string', 'max:1000'],
            'name' => ['required', 'string', 'max:255'],
            'content' => ['nullable', 'string', 'max:'.$ftp->editLimit()],
        ]);

        return $this->attempt(function () use ($data, $ftp) {
            $path = $ftp->makeFile($data['directory'] ?? '', $data['name'], $data['content'] ?? '');

            return response()->json(['path' => $path]);
        });
    }

    public function updateContent(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
            'content' => ['present', 'string', 'max:'.$ftp->editLimit()],
        ]);

        return $this->attempt(function () use ($data, $ftp) {
            $ftp->write($data['path'], $data['content']);

            return response()->json(['path' => $ftp->normalize($data['path'])]);
        });
    }

    public function rename(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
            'name' => ['required', 'string', 'max:255'],
        ]);

        return $this->attempt(fn () => response()->json([
            'path' => $ftp->rename($data['path'], $data['name']),
        ]));
    }

    public function destroy(Request $request, FtpBrowser $ftp): JsonResponse
    {
        if ($denied = $this->guard()) {
            return $denied;
        }

        $data = $request->validate([
            'path' => ['required', 'string', 'max:1000'],
            'type' => ['required', 'in:file,directory'],
        ]);

        return $this->attempt(function () use ($data, $ftp) {
            $ftp->delete($data['path'], $data['type']);

            return response()->json(['deleted' => true]);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function publicState(FtpBrowser $ftp): array
    {
        $configured = $ftp->credentialsConfigured();

        return [
            'connected' => (bool) session('ftp.connected'),
            'configured' => $configured,
            'host' => $configured ? (string) config('filesystems.disks.ftp.host') : null,
            'port' => $configured ? (int) config('filesystems.disks.ftp.port') : null,
            'maxUpload' => $this->maxUploadBytes(),
        ];
    }

    private function guard(): ?JsonResponse
    {
        if (! session('ftp.connected')) {
            return response()->json([
                'message' => 'Connect to the FTP server first.',
            ], 403);
        }

        return null;
    }

    private function attempt(callable $callback): mixed
    {
        try {
            return $callback();
        } catch (InvalidArgumentException|RuntimeException $exception) {
            return response()->json([
                'message' => $exception->getMessage(),
            ], 422);
        } catch (Throwable $exception) {
            report($exception);

            return response()->json([
                'message' => $this->safeMessage($exception),
            ], 422);
        }
    }

    private function safeMessage(Throwable $exception): string
    {
        $message = trim($exception->getMessage());
        $password = (string) config('filesystems.disks.ftp.password');

        if ($password !== '') {
            $message = str_replace($password, '********', $message);
        }

        if ($message === '') {
            return 'The FTP server could not complete that request.';
        }

        if (strlen($message) > 280) {
            return substr($message, 0, 280).'…';
        }

        return $message;
    }

    private function maxUploadBytes(): int
    {
        return $this->iniToBytes((string) ini_get('upload_max_filesize'));
    }

    private function iniToBytes(string $value): int
    {
        $value = trim($value);

        if ($value === '' || $value === '-1') {
            return PHP_INT_MAX;
        }

        $unit = strtolower(substr($value, -1));
        $number = (float) $value;

        $bytes = match ($unit) {
            'g' => $number * 1024 * 1024 * 1024,
            'm' => $number * 1024 * 1024,
            'k' => $number * 1024,
            default => $number,
        };

        return max(1, (int) $bytes);
    }
}
