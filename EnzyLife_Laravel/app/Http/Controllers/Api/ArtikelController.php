<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artikel;

class ArtikelController extends Controller
{
    // Semua artikel
    public function index()
    {
        $artikel = Artikel::latest()->get();

        return response()->json([
            'success' => true,
            'data' => $artikel
        ]);
    }

    // Detail artikel
    public function show($id)
    {
        $artikel = Artikel::find($id);

        if (!$artikel) {
            return response()->json([
                'success' => false,
                'message' => 'Artikel tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $artikel
        ]);
    }
}