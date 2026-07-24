<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LogoutTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_logout_successfully(): void
    {
        $user = User::factory()->create();

        $token = $user->createToken('flutter-app')->plainTextToken;

        $response = $this
            ->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/logout');

        $response
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Logged out',
            ]);

        $this->assertCount(0, $user->fresh()->tokens);
    }

    public function test_guest_cannot_logout(): void
    {
        $response = $this->postJson('/api/logout');

        $response->assertStatus(401);
    }
}