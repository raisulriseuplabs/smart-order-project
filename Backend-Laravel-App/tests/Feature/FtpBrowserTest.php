<?php

namespace Tests\Feature;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class FtpBrowserTest extends TestCase
{
    public function test_welcome_page_includes_the_ftp_drive(): void
    {
        $this->get('/')
            ->assertOk()
            ->assertSee('FTP Drive')
            ->assertSee('id="ftp-app"', false);
    }

    public function test_status_hides_the_host_until_credentials_exist(): void
    {
        config([
            'filesystems.disks.ftp.host' => '',
            'filesystems.disks.ftp.username' => '',
        ]);

        $this->getJson('/ftp/status')
            ->assertOk()
            ->assertJsonPath('configured', false)
            ->assertJsonPath('host', null);

        $this->postJson('/ftp/connect')
            ->assertStatus(422)
            ->assertJsonPath('message', 'Add FTP_HOST, FTP_USERNAME, and FTP_PASSWORD to the .env file, then reload this page.');
    }

    public function test_browser_requires_a_connection_before_reading_files(): void
    {
        $this->getJson('/ftp/list')->assertStatus(403);
    }

    public function test_connected_session_can_manage_files_and_folders(): void
    {
        $this->connect();

        $this->getJson('/ftp/status')
            ->assertOk()
            ->assertJsonPath('connected', true)
            ->assertJsonPath('host', 'ftp.example.com')
            ->assertJsonMissing(['password' => 'secret']);

        Storage::disk('ftp')->put('readme.txt', 'hello');

        $this->getJson('/ftp/list')
            ->assertOk()
            ->assertJsonPath('entries.0.name', 'readme.txt')
            ->assertJsonPath('entries.0.type', 'file');

        $this->postJson('/ftp/folder', ['directory' => '', 'name' => 'orders'])
            ->assertOk()
            ->assertJsonPath('path', 'orders');

        $this->postJson('/ftp/file', [
            'directory' => 'orders',
            'name' => 'note.txt',
            'content' => 'hello',
        ])->assertOk();

        $this->assertSame('hello', Storage::disk('ftp')->get('orders/note.txt'));

        $this->getJson('/ftp/read?path=orders/note.txt')
            ->assertOk()
            ->assertJsonPath('content', 'hello');

        $this->putJson('/ftp/content', [
            'path' => 'orders/note.txt',
            'content' => 'updated',
        ])->assertOk();

        $this->assertSame('updated', Storage::disk('ftp')->get('orders/note.txt'));

        $this->postJson('/ftp/rename', [
            'path' => 'orders/note.txt',
            'name' => 'invoice.txt',
        ])->assertOk()->assertJsonPath('path', 'orders/invoice.txt');

        Storage::disk('ftp')->assertMissing('orders/note.txt');

        $this->post('/ftp/upload', [
            'directory' => 'orders',
            'files' => [UploadedFile::fake()->createWithContent('notes.txt', 'from-upload')],
            'paths' => ['guides/notes.txt'],
        ])->assertOk()->assertJsonPath('uploaded', 1);

        $this->assertSame('from-upload', Storage::disk('ftp')->get('orders/guides/notes.txt'));

        $this->get('/ftp/download?path=orders/invoice.txt')
            ->assertOk()
            ->assertDownload('invoice.txt');

        $this->deleteJson('/ftp/item', [
            'path' => 'orders/invoice.txt',
            'type' => 'file',
        ])->assertOk();

        Storage::disk('ftp')->assertMissing('orders/invoice.txt');

        $this->deleteJson('/ftp/item', [
            'path' => 'orders',
            'type' => 'directory',
        ])->assertOk();

        $this->assertFalse(Storage::disk('ftp')->directoryExists('orders'));
    }

    public function test_paths_cannot_escape_the_ftp_root(): void
    {
        $this->connect();

        $this->getJson('/ftp/list?path='.urlencode('../.env'))->assertStatus(422);
        $this->postJson('/ftp/folder', ['name' => '../secret'])->assertStatus(422);
        $this->deleteJson('/ftp/item', ['path' => '..', 'type' => 'directory'])->assertStatus(422);

        Storage::disk('ftp')->put('secret.bin', "\0\0");

        $this->getJson('/ftp/read?path=secret.bin')
            ->assertStatus(422)
            ->assertJsonPath('message', 'This file looks binary. Download it instead of editing it.');
    }

    public function test_disconnect_closes_the_session(): void
    {
        $this->connect();

        $this->postJson('/ftp/disconnect')
            ->assertOk()
            ->assertJsonPath('connected', false);

        $this->getJson('/ftp/list')->assertStatus(403);
    }

    private function connect(): void
    {
        config([
            'filesystems.disks.ftp.host' => 'ftp.example.com',
            'filesystems.disks.ftp.username' => 'demo',
            'filesystems.disks.ftp.password' => 'secret',
            'filesystems.disks.ftp.port' => 21,
        ]);

        Storage::fake('ftp');

        $this->postJson('/ftp/connect')
            ->assertOk()
            ->assertJsonPath('connected', true)
            ->assertDontSee('secret', false);
    }
}
