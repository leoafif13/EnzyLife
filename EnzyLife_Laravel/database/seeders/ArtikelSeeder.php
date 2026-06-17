<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ArtikelSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('artikel')->insert([

            [
                'judul' => 'Mengenal Ekoenzim: Cairan Ajaib dari Sampah Organik',
                'ringkasan' => 'Ternyata sampah dapur bisa diubah jadi cairan pembersih serbaguna! Ketahui rahasia hemat dan ramah lingkungan dengan ekoenzim.',
                'isi_konten' => 'Mengapa Anda harus mulai membuat ekoenzim hari ini?
- **Hemat Pengeluaran**: Gantikan pembersih lantai, sabun cuci piring, dan detergen kimia di rumah Anda dengan cairan organik alami yang bebas biaya!
- **Keluarga Lebih Sehat**: Katakan selamat tinggal pada paparan residu bahan kimia sintetis yang bisa mengiritasi kulit sensitif keluarga Anda.
- **Aman Bagi Lingkungan**: Air sisa cucian ekoenzim justru membantu membersihkan ekosistem perairan dan tanah di sekitar rumah Anda.
Tertarik untuk mengetahui sejarah lengkap serta pemanfaatan ekoenzim secara mendalam? Jangan lewatkan pembahasan ensiklopedia tepercaya di link berikut!',
                'gambar' => 'artikel1.jpg',
                'kategori' => 'Edukasi, Informasi',
                'tautan' => 'https://id.wikipedia.org/wiki/Ekoenzim',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Rahasia Kebun Subur dan Bebas Hama dengan Eco-Enzyme Cair',
                'ringkasan' => 'Bosan tanaman layu atau diserang hama? Ini dia cara ampuh menyuburkan tanaman hias secara organik menggunakan eco-enzyme!',
                'isi_konten' => 'Ingin kebun atau tanaman hias Anda tumbuh subur, hijau royo-royo, dan terbebas dari hama tanpa pestisida kimia beracun? Eco-enzyme adalah jawabannya!
- **Nutrisi Tanaman Alami**: Berfungsi sebagai pupuk organik cair yang sangat kaya akan nutrisi makro untuk mempercepat pertumbuhan daun dan akar.
- **Pestisida Alami yang Ampuh**: Sifat asam organiknya ampuh mengusir hama tanaman pengganggu tanpa merusak keseimbangan ekosistem tanah.
- **Sangat Mudah & Murah**: Hanya butuh sisa sayur/kulit buah segar, molase/gula merah, dan air bersih dengan perbandingan emas 1:3:10.
Ingin tahu panduan praktis gaya hidup minim sampah dan pengolahan eco-enzyme selengkapnya? Baca tips berkebun organik di tautan resmi berikut!',
                'gambar' => 'artikel2.jpg',
                'kategori' => 'Eco Enzyme, Pertanian, Rumah Tangga',
                'tautan' => 'https://zerowaste.id/zero-waste-lifestyle/eco-enzyme/',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Manfaat Hebat Eco-Enzyme Bagi Lingkungan dan Kesehatan',
                'ringkasan' => 'Ingin tahu apa saja manfaat medis dan ekologis dari eco-enzyme? Yuk pelajari kegunaan cairan serbaguna ini bagi tubuh dan lingkungan sekitar!',
                'isi_konten' => 'Eco-enzyme tidak hanya membantu melestarikan bumi kita, tetapi juga memiliki peranan penting bagi kebersihan harian keluarga Anda:
- **Pembersih Serbaguna**: Alternatif pembersih lantai, kompor, toilet, hingga detergen pakaian ramah lingkungan dengan sifat antibakteri alami.
- **Detoksifikasi Lingkungan**: Membantu menurunkan angka kuman udara, menjernihkan air tercemar, dan mereduksi tumpukan sampah makanan di TPA.
- **Keamanan Penggunaan**: Pelajari batasan dan cara aman penggunaannya agar tidak menimbulkan iritasi pada kulit sensitif keluarga Anda.
Hindari kesalahan fatal dalam pengaplikasiannya dengan membaca ulasan kesehatan dan petunjuk medis tepercaya di tautan resmi berikut!',
                'gambar' => 'artikel3.jpg',
                'kategori' => 'Edukasi, Kesehatan, Lingkungan',
                'tautan' => 'https://www.halodoc.com/artikel/mengenal-eco-enzyme-dan-manfaatnya-bagi-lingkungan',
                'created_at' => now(),
                'updated_at' => now(),
            ],

        ]);
    }
}
