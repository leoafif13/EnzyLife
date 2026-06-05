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
       Schema::create('pembayaran', function (Blueprint $table) {
            $table->id();

            $table->foreignId('pemesanan_id')
                ->constrained('pemesanan')
                ->cascadeOnDelete();

            $table->decimal('total_bayar', 12, 2);

            $table->string('payment_type')->nullable();

            $table->string('midtrans_order_id')->nullable();

            $table->enum('status_pembayaran', [
                'BELUM_DIBAYAR',
                'PENDING',
                'SUDAH_DIBAYAR',
                'EXPIRE',
                'CANCEL',
                'DENY'
            ])->default('BELUM_DIBAYAR');

            $table->timestamp('tanggal_pembayaran')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('pembayaran');
    }
};
