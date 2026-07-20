<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\Pembayaran;
use Illuminate\Foundation\Testing\RefreshDatabase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    public function test_online_payment_successfully_verified()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'metode_pembayaran' => 'ONLINE',
            'status_pemesanan' => 'MENUNGGU_PEMBAYARAN',
        ]);

        Pembayaran::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'status_pembayaran' => 'BELUM_DIBAYAR',
            'midtrans_order_id' => 'TEST123',
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson("/api/orders/{$pemesanan->id}/pay?simulate=true");

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseHas('pembayaran', [
            'pemesanan_id' => $pemesanan->id,
            'status_pembayaran' => 'SUDAH_DIBAYAR',
        ]);

        $this->assertDatabaseHas('pemesanan', [
            'id' => $pemesanan->id,
            'status_pemesanan' => 'DIPROSES',
        ]);
    }

    public function test_guest_cannot_pay_order()
    {
        $pemesanan = Pemesanan::factory()->create();

        $response = $this->postJson("/api/orders/{$pemesanan->id}/pay");

        $response->assertStatus(401);
    }

    public function test_cod_order_cannot_be_paid()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'metode_pembayaran' => 'COD',
            'status_pemesanan' => 'DIKEMAS',
        ]);

        Pembayaran::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'status_pembayaran' => 'BELUM_DIBAYAR',
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->postJson("/api/orders/{$pemesanan->id}/pay");

        $response
            ->assertStatus(400)
            ->assertJson([
                'success' => false,
            ]);
    }

    public function test_payment_status_changes_after_successful_payment()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $pemesanan = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'metode_pembayaran' => 'ONLINE',
            'status_pemesanan' => 'MENUNGGU_PEMBAYARAN',
        ]);

        Pembayaran::factory()->create([
            'pemesanan_id' => $pemesanan->id,
            'status_pembayaran' => 'BELUM_DIBAYAR',
            'midtrans_order_id' => 'ORDER123',
        ]);

        $this
            ->actingAs($user, 'sanctum')
            ->postJson("/api/orders/{$pemesanan->id}/pay?simulate=true");

        $pemesanan->refresh();
        $pembayaran = Pembayaran::where('pemesanan_id', $pemesanan->id)->first();

        $this->assertEquals('DIPROSES', $pemesanan->status_pemesanan);
        $this->assertEquals('SUDAH_DIBAYAR', $pembayaran->status_pembayaran);
    }
}