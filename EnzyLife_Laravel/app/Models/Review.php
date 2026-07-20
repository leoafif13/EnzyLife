<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Review extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'pemesanan_id',
        'produk_id',
        'rating',
        'komentar_aroma',
        'komentar_pengiriman',
        'sentiment_score',
        'sentiment_label',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function produk()
    {
        return $this->belongsTo(Product::class, 'produk_id');
    }

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }

    public function sentimentByProduct($produkId)
    {
        $reviews = Review::where('produk_id', $produkId)->get();

        $total = $reviews->count();

        if ($total == 0) {
            return response()->json([
                'positif' => 0,
                'netral' => 0,
                'negatif' => 0,
                'total' => 0,
                'comments' => [
                    'positif' => [],
                    'netral' => [],
                    'negatif' => [],
                ]
            ]);
        }

        $positif = $reviews->where('sentiment_label', 'positif')->count();
        $netral = $reviews->where('sentiment_label', 'netral')->count();
        $negatif = $reviews->where('sentiment_label', 'negatif')->count();

        return response()->json([
            'total' => $total,

            'positif' => round(($positif / $total) * 100, 1),
            'netral' => round(($netral / $total) * 100, 1),
            'negatif' => round(($negatif / $total) * 100, 1),

            'comments' => [
                'positif' => $reviews
                    ->where('sentiment_label', 'positif')
                    ->pluck('komentar_aroma')
                    ->values(),

                'netral' => $reviews
                    ->where('sentiment_label', 'netral')
                    ->pluck('komentar_aroma')
                    ->values(),

                'negatif' => $reviews
                    ->where('sentiment_label', 'negatif')
                    ->pluck('komentar_aroma')
                    ->values(),
            ]
        ]);
    }
}