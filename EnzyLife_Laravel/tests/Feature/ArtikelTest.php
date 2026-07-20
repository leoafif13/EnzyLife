<?php

namespace Tests\Feature;

use App\Models\Artikel;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ArtikelTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_view_all_articles(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        Artikel::factory()->count(5)->create();

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson('/api/artikel');

        $response->assertStatus(200);
    }

    public function test_user_can_view_article_detail(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $artikel = Artikel::factory()->create();

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson("/api/artikel/{$artikel->id}");

        $response->assertStatus(200);
    }

    public function test_user_cannot_view_nonexistent_article(): void
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson('/api/artikel/999999');

        $response->assertStatus(404);
    }
}