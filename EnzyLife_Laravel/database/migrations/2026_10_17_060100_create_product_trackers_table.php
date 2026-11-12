<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_trackers', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('pemesanan_id')
                ->constrained('pemesanan')
                ->cascadeOnDelete();

            $table->foreignId('produk_id')
                ->constrained('products')
                ->cascadeOnDelete();

            // 1 tracker per produk per pesanan
            $table->unique(['user_id', 'pemesanan_id', 'produk_id']);

            $table->date('tanggal_mulai');

            // Default 3 minggu dari tanggal_mulai
            $table->date('tanggal_selesai');

            // Jika diperpanjang, max +2 minggu (total max 5 minggu)
            $table->date('tanggal_perpanjangan')->nullable();

            // Catatan hasil akhir setelah selesai tracking
            $table->text('catatan_hasil')->nullable();

            $table->enum('status', [
                'AKTIF',
                'PERPANJANGAN',
                'SELESAI',
                'DIBATALKAN',
            ])->default('AKTIF');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('product_trackers');
    }
};
