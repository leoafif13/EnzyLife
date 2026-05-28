<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('products')->insert([
            [
                'nama' => 'Eco Enzyme Citrus',
                'harga' => 25000,
                'deskripsi' => 'Eco enzyme aroma citrus untuk pembersih alami dan pupuk organik.',
                'stok' => 20,
                'gambar' => 'eco-citrus.jpg',
            ],

            [
                'nama' => 'Eco Enzyme Original',
                'harga' => 30000,
                'deskripsi' => 'Eco enzyme serbaguna hasil fermentasi organik alami.',
                'stok' => 15,
                'gambar' => 'eco-original.jpg',
            ],

            [
                'nama' => 'Eco Enzyme Lavender',
                'harga' => 35000,
                'deskripsi' => 'Eco enzyme dengan aroma lavender menyegarkan.',
                'stok' => 10,
                'gambar' => 'eco-lavender.jpg',
            ],
        ]);
    }
}
