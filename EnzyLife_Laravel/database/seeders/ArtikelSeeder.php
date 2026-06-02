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
                'judul' => 'Apa Itu Eco Enzyme dan Mengapa Semakin Populer?',
                'ringkasan' => 'Eco enzyme mulai dikenal luas sebagai solusi ramah lingkungan yang murah dan mudah dibuat.',
                'isi_konten' => 'Eco enzyme adalah cairan hasil fermentasi limbah organik seperti kulit buah dan sayuran yang dicampur dengan gula serta air. Dalam beberapa tahun terakhir, eco enzyme semakin populer karena dianggap sebagai solusi sederhana untuk mengurangi sampah organik rumah tangga sekaligus menghasilkan cairan multifungsi.
Banyak orang awalnya menganggap eco enzyme hanya sekadar tren lingkungan. Namun setelah dicoba langsung, mereka mulai menyadari bahwa cairan ini benar-benar memiliki banyak manfaat praktis. Eco enzyme dapat digunakan sebagai pupuk alami, cairan pembersih lantai, penghilang bau, hingga campuran untuk perawatan tanaman.
Proses pembuatannya pun relatif mudah. Bahan utama yang dibutuhkan hanyalah limbah organik segar, gula merah atau molase, dan air bersih. Semua bahan difermentasikan selama kurang lebih tiga bulan di wadah tertutup.
Meski terlihat sederhana, proses fermentasi menghasilkan berbagai mikroorganisme dan enzim alami yang bermanfaat bagi lingkungan. Karena itu eco enzyme dianggap lebih aman dibanding banyak produk kimia rumah tangga.
Selain membantu mengurangi limbah dapur, penggunaan eco enzyme juga mulai diterapkan di berbagai komunitas lingkungan, sekolah, dan program edukasi masyarakat sebagai bagian dari gaya hidup berkelanjutan.',
                'gambar' => 'artikel1.jpg',
                'kategori' => 'Artikel',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => '5 Kesalahan Umum Saat Membuat Eco Enzyme',
                'ringkasan' => 'Banyak pemula gagal membuat eco enzyme karena kesalahan sederhana yang sebenarnya bisa dihindari.',
                'isi_konten' => 'Membuat eco enzyme memang terlihat mudah, tetapi banyak orang gagal pada percobaan pertama karena kurang memahami proses fermentasi yang benar. Salah satu kesalahan paling umum adalah menggunakan bahan organik yang sudah membusuk. Padahal bahan yang terlalu busuk dapat menghasilkan aroma yang tidak normal dan merusak fermentasi.
Kesalahan kedua adalah rasio bahan yang tidak sesuai. Eco enzyme memiliki perbandingan dasar 1:3:10, yaitu satu bagian gula, tiga bagian limbah organik, dan sepuluh bagian air. Jika perbandingan ini tidak tepat, proses fermentasi bisa terganggu.
Selain itu, banyak orang menggunakan wadah terlalu penuh tanpa menyisakan ruang udara. Padahal selama fermentasi akan terbentuk gas yang cukup banyak. Jika wadah terlalu penuh, tutup bisa terbuka sendiri atau bahkan wadah rusak.
Kesalahan lainnya adalah terlalu sering membuka wadah. Banyak pemula penasaran dan terus mengecek isi fermentasi setiap hari. Akibatnya bakteri dari luar masuk dan mengganggu proses alami di dalam wadah.
Terakhir, kurang sabar juga menjadi masalah utama. Eco enzyme membutuhkan waktu minimal tiga bulan agar fermentasi matang sempurna. Membuka atau menggunakan cairan terlalu cepat biasanya menghasilkan kualitas yang kurang baik.',
                'gambar' => 'artikel2.jpg',
                'kategori' => 'Artikel',
                'created_at' => now(),
                'updated_at' => now(),
            ],

            [
                'judul' => 'Workshop Eco Enzyme di Sekolah Mulai Diminati',
                'ringkasan' => 'Program edukasi eco enzyme mulai diterapkan di berbagai sekolah sebagai bagian dari pendidikan lingkungan.',
                'isi_konten' => 'Kesadaran terhadap pentingnya pengelolaan sampah organik mulai meningkat di lingkungan sekolah. Salah satu program yang kini banyak diterapkan adalah workshop pembuatan eco enzyme untuk siswa.
Melalui kegiatan ini, siswa diajarkan bagaimana limbah dapur yang biasanya dibuang ternyata masih memiliki nilai guna tinggi. Kulit buah, sisa sayuran, dan bahan organik lainnya dapat diolah menjadi cairan fermentasi multifungsi yang ramah lingkungan.
Beberapa sekolah bahkan menjadikan program ini sebagai proyek rutin bulanan. Selain mengurangi sampah kantin, kegiatan tersebut juga membantu siswa memahami konsep daur ulang dan keberlanjutan secara langsung.
Guru pendamping mengaku siswa lebih antusias belajar ketika praktik dilakukan secara nyata dibanding hanya membaca teori di kelas. Mereka dapat melihat sendiri proses fermentasi dan perubahan yang terjadi dari waktu ke waktu.
Program seperti ini dinilai efektif membangun kebiasaan peduli lingkungan sejak usia dini. Banyak orang tua siswa juga mulai tertarik mencoba membuat eco enzyme di rumah setelah melihat hasil karya anak-anak mereka.',
                'gambar' => 'artikel3.jpg',
                'kategori' => 'Artikel',
                'created_at' => now(),
                'updated_at' => now(),
            ],

        ]);
    }
}
