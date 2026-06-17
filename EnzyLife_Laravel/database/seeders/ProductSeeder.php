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
                'spesifikasi' => json_encode([
                    'Volume' => '500 ml',
                    'Bahan' => 'Kulit Jeruk Citrus, Air, Molase',
                    'Lama Fermentasi' => '3 Bulan',
                    'Masa Simpan' => '12 Bulan',
                ]),
            ],

            [
                'nama' => 'Eco Enzyme Original',
                'harga' => 30000,
                'deskripsi' => 'Eco enzyme serbaguna hasil fermentasi organik alami.',
                'stok' => 15,
                'gambar' => 'eco-original.jpg',
                'spesifikasi' => json_encode([
                    'Volume' => '1 Liter',
                    'Bahan' => 'Kulit Buah Campur, Air, Molase',
                    'Lama Fermentasi' => '3 Bulan',
                    'Masa Simpan' => '24 Bulan',
                ]),
            ],

            [
                'nama' => 'Eco Enzyme Lavender',
                'harga' => 35000,
                'deskripsi' => 'Eco enzyme dengan aroma lavender menyegarkan.',
                'stok' => 10,
                'gambar' => 'eco-lavender.jpg',
                'spesifikasi' => json_encode([
                    'Volume' => '500 ml',
                    'Bahan' => 'Bunga Lavender, Kulit Buah, Air',
                    'Lama Fermentasi' => '3 Bulan',
                    'Masa Simpan' => '12 Bulan',
                ]),
            ],
        ]);
    }
}
