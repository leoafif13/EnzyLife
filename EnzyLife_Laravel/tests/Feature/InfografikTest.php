<?php

namespace Tests\Feature;

use App\Models\Infografik;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InfografikTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_view_all_infografik(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        Infografik::factory()->count(5)->create();

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson('/api/infografik');

        $response->assertStatus(200);
    }

    public function test_user_can_view_infografik_detail(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $infografik = Infografik::factory()->create();

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson("/api/infografik/{$infografik->id}");

        $response->assertStatus(200);
    }

    public function test_user_cannot_view_nonexistent_infografik(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson('/api/infografik/999999');

        $response->assertStatus(404);
    }
}