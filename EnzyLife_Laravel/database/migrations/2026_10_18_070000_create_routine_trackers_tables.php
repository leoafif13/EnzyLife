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
        Schema::create('user_routines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('tracker_id')->nullable()->constrained('product_trackers')->onDelete('cascade');
            $table->foreignId('pemesanan_id')->nullable()->constrained('pemesanan')->nullOnDelete();
            $table->foreignId('produk_id')->nullable()->constrained('products')->nullOnDelete();
            $table->string('kategori_nama');
            $table->enum('tipe_target', ['HARIAN', 'MINGGUAN', 'FLEKSIBEL'])->default('MINGGUAN');
            $table->integer('target_min')->default(2);
            $table->integer('target_max')->default(3);
            $table->decimal('takaran_ml_per_pakai', 8, 2)->default(50.00);
            $table->string('jam_pengingat', 10)->default('19:00');
            $table->date('tanggal_mulai_siklus');
            $table->integer('siklus_ke')->default(1);
            $table->enum('status_rutinitas', ['AKTIF', 'JEDA', 'SELESAI'])->default('AKTIF');
            $table->integer('stok_awal_ml')->default(1000);
            $table->decimal('stok_sisa_ml', 8, 2)->default(1000.00);
            $table->timestamps();
        });

        Schema::create('routine_checkins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_routine_id')->constrained('user_routines')->onDelete('cascade');
            $table->integer('siklus_ke')->default(1);
            $table->integer('hari_ke')->default(1);
            $table->date('tanggal');
            $table->time('waktu');
            $table->timestamps();

            // Mencegah double check-in pada rutinitas yang sama di hari yang sama
            $table->unique(['user_routine_id', 'tanggal']);
        });

        Schema::create('weekly_summaries', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('tracker_id')->nullable()->constrained('product_trackers')->onDelete('cascade');
            $table->foreignId('user_routine_id')->constrained('user_routines')->onDelete('cascade');
            $table->integer('siklus_ke')->default(1);
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai');
            $table->integer('total_checkin')->default(0);
            $table->integer('target_min')->default(1);
            $table->integer('target_max')->default(7);
            $table->enum('status_pencapaian', ['BELUM_TERCAPAI', 'TERCAPAI', 'OPTIMAL', 'FLEKSIBEL'])->default('BELUM_TERCAPAI');
            $table->decimal('estimasi_ml_terpakai', 8, 2)->default(0.00);
            $table->decimal('sisa_ml_stok', 8, 2)->default(1000.00);
            $table->string('chip_feedback')->nullable();
            $table->text('catatan_refleksi')->nullable();
            $table->boolean('is_reviewed')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('weekly_summaries');
        Schema::dropIfExists('routine_checkins');
        Schema::dropIfExists('user_routines');
    }
};
