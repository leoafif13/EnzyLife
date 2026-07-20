<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'nama',
        'harga',
        'deskripsi',
        'stok',
        'gambar',
        'spesifikasi',
    ];

    protected $casts = [
        'spesifikasi' => 'array',
    ];

    public function detailPemesanan()
    {
        return $this->hasMany(DetailPemesanan::class, 'produk_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'produk_id');
    }
}