<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;

class CheckoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_checkout_cod()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create([
            'harga' => 10000,
            'stok' => 10,
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/checkout', [
                'items' => [
                    [
                        'produk_id' => $produk->id,
                        'qty' => 2,
                    ],
                ],
                'metode_pembayaran' => 'COD',
                'jenis_cod' => 'AMBIL_TEMPAT',
            ]);

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseHas('pemesanan', [
            'user_id' => $user->id,
            'status_pemesanan' => 'DIKEMAS',
        ]);

        $this->assertDatabaseHas('detail_pemesanan', [
            'produk_id' => $produk->id,
            'kuantitas' => 2,
        ]);

        $this->assertDatabaseHas('pembayaran', [
            'payment_type' => 'COD',
            'status_pembayaran' => 'BELUM_DIBAYAR',
        ]);
    }

    public function test_checkout_fails_if_stock_is_not_enough()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create([
            'stok' => 1,
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/checkout', [
                'items' => [
                    [
                        'produk_id' => $produk->id,
                        'qty' => 5,
                    ],
                ],
                'metode_pembayaran' => 'COD',
                'jenis_cod' => 'AMBIL_TEMPAT',
            ]);

        $response->assertStatus(400);
    }

    public function test_guest_cannot_checkout()
    {
        $produk = Product::factory()->create();

        $response = $this->postJson('/api/checkout', [
            'items' => [
                [
                    'produk_id' => $produk->id,
                    'qty' => 1,
                ],
            ],
            'metode_pembayaran' => 'COD',
            'jenis_cod' => 'AMBIL_TEMPAT',
        ]);

        $response->assertStatus(401);
    }

    public function test_stock_decreases_after_checkout()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create([
            'stok' => 10,
        ]);

        $this
            ->actingAs($user, 'sanctum')
            ->postJson('/api/checkout', [
                'items' => [
                    [
                        'produk_id' => $produk->id,
                        'qty' => 3,
                    ],
                ],
                'metode_pembayaran' => 'COD',
                'jenis_cod' => 'AMBIL_TEMPAT',
            ]);

        $produk->refresh();

        $this->assertEquals(7, $produk->stok);
    }
}