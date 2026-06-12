<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $fillable = [
        'nama',
        'harga',
        'deskripsi',
        'stok',
        'gambar',
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
