<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_percakapan', function (Blueprint $table) {
            $table->id('id_percakapan');

            $table->foreignId('id_pelanggan')
                ->constrained('users')
                ->cascadeOnDelete();

            $table->string('judul')->default('Percakapan Baru');
            $table->boolean('disimpan')->default(false);
            $table->string('feedback')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_percakapan');
    }
};
