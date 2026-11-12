<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_pesan', function (Blueprint $table) {
            $table->id('id_pesan');

            $table->foreignId('id_percakapan')
                ->constrained('ai_percakapan', 'id_percakapan')
                ->cascadeOnDelete();

            $table->enum('peran', ['user', 'assistant']);
            $table->longText('isi');

            $table->timestamps();

            $table->index(['id_percakapan', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_pesan');
    }
};
