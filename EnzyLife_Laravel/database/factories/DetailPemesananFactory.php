<?php

namespace Database\Factories;

use App\Models\Pemesanan;
use App\Models\Product;
use App\Models\DetailPemesanan;
use Illuminate\Database\Eloquent\Factories\Factory;

class DetailPemesananFactory extends Factory
{
    protected $model = DetailPemesanan::class;

    public function definition(): array
    {
        $qty = fake()->numberBetween(1,5);
        $harga = fake()->numberBetween(10000,50000);

        return [
            'pemesanan_id' => Pemesanan::factory(),
            'produk_id' => Product::factory(),

            'kuantitas' => $qty,

            'harga' => $harga,

            'subtotal' => $qty * $harga,
        ];
    }
}