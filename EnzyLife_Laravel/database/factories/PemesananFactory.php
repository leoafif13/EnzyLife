<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PemesananFactory extends Factory
{
    public function definition(): array
    {
        $metode = fake()->randomElement([
            'COD',
            'ONLINE',
        ]);

        return [
            'user_id' => User::factory(),

            'total_harga' => fake()->numberBetween(50000, 300000),

            'metode_pembayaran' => $metode,

            'jenis_cod' => $metode === 'COD'
                ? fake()->randomElement([
                    'AMBIL_TEMPAT',
                    'BAYAR_DI_RUMAH',
                ])
                : null,

            'status_pemesanan' => 'MENUNGGU_PEMBAYARAN',

            'tanggal_pemesanan' => now(),
        ];
    }
}