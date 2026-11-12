<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->boolean('is_verified')
                ->default(false)
                ->after('sentiment_label');

            $table->foreignId('tracker_id')
                ->nullable()
                ->after('is_verified')
                ->constrained('product_trackers')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropForeign(['tracker_id']);
            $table->dropColumn(['is_verified', 'tracker_id']);
        });
    }
};
