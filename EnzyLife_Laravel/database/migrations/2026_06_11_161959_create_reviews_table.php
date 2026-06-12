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
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')
                ->constrained()
                ->cascadeOnDelete();

            $table->foreignId('pemesanan_id')
                ->unique()
                ->constrained('pemesanan')
                ->cascadeOnDelete();

            $table->foreignId('produk_id')
                ->constrained('products')
                ->cascadeOnDelete();

            $table->tinyInteger('rating');

            $table->text('komentar_aroma');

            $table->text('komentar_pengiriman')
                ->nullable();

            // hasil AI
            $table->decimal('sentiment_score', 8, 4)
                ->nullable();

            $table->enum('sentiment_label', [
                'positif',
                'netral',
                'negatif'
            ])->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
