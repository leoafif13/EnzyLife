<?php

use Illuminate\Support\Facades\File;

Route::get('/gambar/{folder}/{filename}', function ($folder, $filename) {

    $path = storage_path("app/public/$folder/" . $filename);

    if (!File::exists($path)) {
        abort(404);
    }

    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*',
    ]);
});

Route::get('/test-env', function () {
    return response()->json([
        'env_server' => env('MIDTRANS_SERVER_KEY'),
        'config_server' => config('midtrans.server_key'),
    ]);
});