<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
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
}