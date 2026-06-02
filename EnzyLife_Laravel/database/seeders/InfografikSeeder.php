<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class InfografikSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('infografik')->insert([
            [
                'judul' => 'Panduan Cara Membuat Eco Enzyme',
                'deskripsi' => 'Langkah-langkah pembuatan Eco Enzyme mulai dari persiapan bahan, rasio campuran, proses fermentasi hingga penyimpanan hasil akhir. Cocok untuk pemula yang ingin memanfaatkan limbah organik rumah tangga menjadi produk yang bermanfaat.',
                'gambar' => 'infografik/panduan-eco-enzyme.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Manfaat Eco Enzyme untuk Tanaman',
                'deskripsi' => 'Infografik mengenai manfaat Eco Enzyme sebagai pupuk cair organik, peningkat kesuburan tanah, serta pengendali hama alami yang ramah lingkungan dan aman digunakan untuk berbagai jenis tanaman.',
                'gambar' => 'infografik/manfaat-tanaman.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Jenis Limbah Organik yang Cocok',
                'deskripsi' => 'Berisi daftar limbah organik yang direkomendasikan untuk pembuatan Eco Enzyme seperti kulit jeruk, nanas, pepaya, apel, dan sayuran segar serta bahan yang sebaiknya dihindari.',
                'gambar' => 'infografik/limbah-organik.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Kesalahan Umum Saat Fermentasi',
                'deskripsi' => 'Menjelaskan beberapa kesalahan yang sering terjadi saat proses fermentasi Eco Enzyme seperti penggunaan wadah logam, perbandingan bahan yang tidak tepat, dan penyimpanan di tempat yang tidak sesuai.',
                'gambar' => 'infografik/kesalahan-fermentasi.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Pemanfaatan Eco Enzyme di Rumah',
                'deskripsi' => 'Panduan penggunaan Eco Enzyme sebagai pembersih lantai, penghilang bau, pembersih dapur, dan kebutuhan rumah tangga lainnya yang lebih ramah lingkungan dibanding bahan kimia sintetis.',
                'gambar' => 'infografik/pemanfaatan-rumah.jpg',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}
