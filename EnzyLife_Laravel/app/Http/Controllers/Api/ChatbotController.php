<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use Illuminate\Support\Facades\Http;

class ChatbotController extends Controller
{
    public function products()
    {
        return Product::select(
            'id',
            'nama',
            'harga',
            'deskripsi'
        )->get();
    }

    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string',
        ]);

        try {
            $response = Http::timeout(15)->post(
                'http://127.0.0.1:8001/chat',
                [
                    'message' => $request->message
                ]
            );

            if ($response->successful()) {
                return response()->json($response->json());
            }

            return response()->json([
                'reply' => 'Maaf, terjadi kesalahan saat menghubungi server AI.'
            ], 500);

        } catch (\Exception $e) {
            return response()->json([
                'reply' => 'Maaf, chatbot sedang tidak aktif. Silakan hubungkan server AI (FastAPI) Anda.'
            ], 500);
        }
    }
}

