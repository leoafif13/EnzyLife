<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory
{
    public function definition(): array
    {
        return [

            'nama' => fake()->randomElement([
                'Eco Enzyme Lemon',
                'Eco Enzyme Orange',
                'Eco Enzyme Lavender',
                'Eco Enzyme Mint',
                'Eco Enzyme Jahe',
            ]),

            'harga' => fake()->numberBetween(15000, 50000),

            'deskripsi' => fake()->sentence(10),

            'stok' => fake()->numberBetween(10, 100),

            'gambar' => 'produk.jpg',

            'spesifikasi' => [
                'Aroma' => fake()->randomElement([
                    'Lemon',
                    'Orange',
                    'Mint',
                    'Lavender',
                    'Jahe',
                ]),
                'Volume' => fake()->randomElement([
                    '250 ml',
                    '500 ml',
                    '1000 ml',
                ]),
                'Manfaat' => fake()->randomElement([
                    'Pembersih',
                    'Pupuk',
                    'Penghilang Bau',
                ]),
            ],
        ];
    }
}