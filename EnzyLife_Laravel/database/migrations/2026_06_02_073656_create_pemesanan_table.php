<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('pemesanan', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->decimal('total_harga', 12, 2);

            $table->enum('metode_pembayaran', [
                'COD',
                'ONLINE'
            ]);

            $table->enum('jenis_cod', [
                'AMBIL_TEMPAT',
                'BAYAR_DI_RUMAH'
            ])->nullable();

            $table->enum('status_pemesanan', [
                'MENUNGGU_PEMBAYARAN',
                'DIPROSES',
                'DIKEMAS',
                'DIKIRIM',
                'SIAP_DIAMBIL',
                'SELESAI',
                'DIBATALKAN'
            ])->default('MENUNGGU_PEMBAYARAN');

            $table->timestamp('tanggal_pemesanan')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pemesanan');
    }
};
