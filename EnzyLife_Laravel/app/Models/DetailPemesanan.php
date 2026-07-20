<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class DetailPemesanan extends Model
{
    use HasFactory;
    protected $table = 'detail_pemesanan';

    protected $fillable = [
        'pemesanan_id',
        'produk_id',
        'kuantitas',
        'harga',
        'subtotal',
    ];

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }

    public function produk()
    {
        return $this->belongsTo(Product::class, 'produk_id');
    }
}