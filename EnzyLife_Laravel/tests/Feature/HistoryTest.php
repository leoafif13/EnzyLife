<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Pemesanan;
use Illuminate\Foundation\Testing\RefreshDatabase;

class HistoryTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_view_order_history(): void
    {
        $user = User::factory()->create();

        Pemesanan::factory()->count(3)->create([
            'user_id' => $user->id,
        ]);

        $token = $user->createToken('flutter-app')->plainTextToken;

        $response = $this
            ->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/orders');

        $response
            ->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertCount(3, $response->json('data'));
    }

    public function test_guest_cannot_view_order_history(): void
    {
        $response = $this->getJson('/api/orders');

        $response->assertStatus(401);
    }

    public function test_user_only_sees_their_own_orders(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();

        Pemesanan::factory()->count(2)->create([
            'user_id' => $user->id,
        ]);

        Pemesanan::factory()->count(4)->create([
            'user_id' => $otherUser->id,
        ]);

        $token = $user->createToken('flutter-app')->plainTextToken;

        $response = $this
            ->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/orders');

        $response->assertStatus(200);

        $this->assertCount(2, $response->json('data'));
    }

    public function test_order_history_is_sorted_by_latest(): void
    {
        $user = User::factory()->create();

        $old = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'created_at' => now()->subDays(2),
        ]);

        $new = Pemesanan::factory()->create([
            'user_id' => $user->id,
            'created_at' => now(),
        ]);

        $token = $user->createToken('flutter-app')->plainTextToken;

        $response = $this
            ->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/orders');

        $response->assertStatus(200);

        $this->assertEquals(
            $new->id,
            $response->json('data.0.id')
        );
    }
}