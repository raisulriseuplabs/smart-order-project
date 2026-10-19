<?php

use App\Http\Controllers\FtpBrowserController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::prefix('ftp')->group(function () {
    Route::get('/status', [FtpBrowserController::class, 'status']);
    Route::post('/connect', [FtpBrowserController::class, 'connect']);
    Route::post('/disconnect', [FtpBrowserController::class, 'disconnect']);
    Route::get('/list', [FtpBrowserController::class, 'list']);
    Route::get('/read', [FtpBrowserController::class, 'read']);
    Route::get('/download', [FtpBrowserController::class, 'download']);
    Route::post('/upload', [FtpBrowserController::class, 'upload']);
    Route::post('/folder', [FtpBrowserController::class, 'makeDirectory']);
    Route::post('/file', [FtpBrowserController::class, 'makeFile']);
    Route::put('/content', [FtpBrowserController::class, 'updateContent']);
    Route::post('/rename', [FtpBrowserController::class, 'rename']);
    Route::delete('/item', [FtpBrowserController::class, 'destroy']);
});
