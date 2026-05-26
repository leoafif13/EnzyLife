<?php

use Illuminate\Support\Facades\File;

Route::get('/gambar/{filename}', function ($filename) {

    $path = storage_path('app/public/produk/' . $filename);

    if (!File::exists($path)) {
        abort(404);
    }

    return response()->file($path, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
    ]);
});