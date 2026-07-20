<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\DetailPemesanan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;

class ReviewTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_submit_review()
    {
        Http::fake([
            '*' => Http::response([
                'label' => 'positif',
                'score' => 92.5,
            ], 200),
        ]);

        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'status_pemesanan' => 'SELESAI',
        ]);

        DetailPemesanan::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/review', [
                'pemesanan_id' => $pemesanan->id,
                'produk_id' => $produk->id,
                'rating' => 5,
                'komentar_aroma' => 'Aromanya sangat segar',
                'komentar_pengiriman' => 'Cepat',
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('reviews', [
            'produk_id' => $produk->id,
            'rating' => 5,
            'sentiment_label' => 'positif',
        ]);
    }

    public function test_user_cannot_review_unfinished_order()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'status_pemesanan' => 'DIKIRIM',
        ]);

        DetailPemesanan::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/review', [
                'pemesanan_id' => $pemesanan->id,
                'produk_id' => $produk->id,
                'rating' => 5,
                'komentar_aroma' => 'Bagus',
            ]);

        $response->assertStatus(400);
    }

    public function test_review_is_updated_not_created_twice()
    {
        Http::fake([
            '*' => Http::response([
                'label' => 'positif',
                'score' => 95,
            ], 200),
        ]);

        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'status_pemesanan' => 'SELESAI',
        ]);

        DetailPemesanan::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
        ]);

        $this->actingAs($user, 'sanctum')->postJson('/api/review', [
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
            'rating' => 5,
            'komentar_aroma' => 'Mantap',
        ]);

        $this->actingAs($user, 'sanctum')->postJson('/api/review', [
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
            'rating' => 3,
            'komentar_aroma' => 'Lumayan',
        ]);

        $this->assertDatabaseCount('reviews', 1);

        $this->assertDatabaseHas('reviews', [
            'rating' => 3,
        ]);
    }

    public function test_review_saved_when_ai_service_is_down()
    {
        Http::fake(function () {
            throw new \Exception('FastAPI Down');
        });

        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'status_pemesanan' => 'SELESAI',
        ]);

        DetailPemesanan::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'produk_id' => $produk->id,
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/review', [
                'pemesanan_id' => $pemesanan->id,
                'produk_id' => $produk->id,
                'rating' => 5,
                'komentar_aroma' => 'Bagus',
            ]);

        $response->assertStatus(200);

        $this->assertDatabaseHas('reviews', [
            'produk_id' => $produk->id,
        ]);
    }
}