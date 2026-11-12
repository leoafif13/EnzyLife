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
        'kategori',
    ];

    public const KATEGORI_OPTIONS = [
        'Kompor & Area Dapur' => 'Kompor & Area Dapur (Rumah Tangga)',
        'Pel Lantai' => 'Pel Lantai (Rumah Tangga)',
        'Cuci Piring' => 'Cuci Piring (Rumah Tangga)',
        'Cuci Pakaian' => 'Cuci Pakaian (Rumah Tangga)',
        'Kamar Mandi' => 'Kamar Mandi (Rumah Tangga)',
        'Saluran Air' => 'Saluran Air (Rumah Tangga)',
        'Penghilang Bau' => 'Penghilang Bau (Rumah Tangga)',
        'Pupuk Organik' => 'Pupuk Organik (Pertanian)',
        'Pestisida Sayuran' => 'Pestisida Sayuran (Pertanian)',
        'Kompos' => 'Kompos (Pertanian)',
        'Air Purifier' => 'Air Purifier (Lingkungan)',
    ];

    protected $casts = [
        'spesifikasi' => 'array',
        'kategori' => 'array',
    ];

    public function detailPemesanan()
    {
        return $this->hasMany(DetailPemesanan::class, 'produk_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'produk_id');
    }

    public function trackers()
    {
        return $this->hasMany(ProductTracker::class, 'produk_id');
    }
}