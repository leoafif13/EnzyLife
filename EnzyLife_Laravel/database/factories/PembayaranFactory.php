<?php

namespace Database\Factories;

use App\Models\Pembayaran;
use App\Models\Pemesanan;
use Illuminate\Database\Eloquent\Factories\Factory;

class PembayaranFactory extends Factory
{
    protected $model = Pembayaran::class;

    public function definition(): array
    {
        return [
            'pemesanan_id' => Pemesanan::factory(),
            'total_bayar' => fake()->numberBetween(10000, 500000),
            'payment_type' => 'COD',
            'midtrans_order_id' => null,
            'snap_token' => null,
            'status_pembayaran' => 'BELUM_DIBAYAR',
            'tanggal_pembayaran' => null,
        ];
    }
}