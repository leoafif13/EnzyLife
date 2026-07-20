<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class InfografikFactory extends Factory
{
    public function definition(): array
    {
        return [
            'judul' => fake()->sentence(5),

            'deskripsi' => fake()->paragraph(),

            'gambar' => 'infografik.jpg',
        ];
    }
}