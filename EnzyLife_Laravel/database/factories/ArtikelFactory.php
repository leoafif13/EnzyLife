<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class ArtikelFactory extends Factory
{
    public function definition(): array
    {
        return [
            'judul' => fake()->sentence(6),

            'ringkasan' => fake()->paragraph(),

            'isi_konten' => fake()->paragraphs(8, true),

            'gambar' => 'artikel.jpg',

            'kategori' => fake()->randomElement([
                'Edukasi',
                'Tips',
                'Lingkungan',
                'Eco Enzyme',
            ]),

            'tautan' => fake()->url(),
        ];
    }
}