<?php

namespace Database\Factories;

use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReviewFactory extends Factory
{
    public function definition(): array
    {
        return [

            'user_id' => User::factory(),

            'pemesanan_id' => Pemesanan::factory(),

            'produk_id' => Product::factory(),

            'rating' => fake()->numberBetween(1, 5),

            'komentar_aroma' => fake()->sentence(),

            'komentar_pengiriman' => fake()->optional()->sentence(),

            'sentiment_label' => fake()->randomElement([
                'positif',
                'netral',
                'negatif',
            ]),

            'sentiment_score' => fake()->randomFloat(2, 40, 99),
        ];
    }
}