<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tracker_logs', function (Blueprint $table) {
            $table->id();

            $table->foreignId('tracker_id')
                ->constrained('product_trackers')
                ->cascadeOnDelete();

            $table->date('tanggal');
            $table->time('waktu');
            $table->text('catatan')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tracker_logs');
    }
};
