<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use App\Models\Pemesanan;
use App\Models\Review;

class ReviewController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'pemesanan_id' => 'required|exists:pemesanan,id',
            'rating' => 'required|integer|min:1|max:5',
            'komentar_aroma' => 'required|string|min:3',
            'komentar_pengiriman' => 'nullable|string',
        ]);

        $pemesanan = Pemesanan::findOrFail(
            $request->pemesanan_id
        );

        // harus milik user login
        if ($pemesanan->user_id != auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak ditemukan'
            ], 403);
        }

        // harus selesai
        if ($pemesanan->status_pemesanan !== 'SELESAI') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan belum selesai'
            ], 400);
        }

        // hanya sekali review
        if ($pemesanan->review) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan sudah direview'
            ], 400);
        }

        $produkId = $pemesanan
            ->detailPemesanan
            ->first()
            ->produk_id;

        $response = Http::post(
            'http://127.0.0.1:8001/predict',
            [
                'komentar' => $request->komentar_aroma
            ]
        );

        if (!$response->successful()) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses analisis sentimen'
            ], 500);
        }

        $sentiment = $response->json();

        $review = Review::create([
            'user_id' => auth()->id(),
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produkId,

            'rating' => $request->rating,

            'komentar_aroma' => $request->komentar_aroma,
            'komentar_pengiriman' => $request->komentar_pengiriman,

            // sementara dummy
            'sentiment_score' => $sentiment['score'],
            'sentiment_label' => $sentiment['label'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Review berhasil disimpan',
            'data' => $review,
        ]);
    }
}