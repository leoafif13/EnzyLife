<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function test_user_can_login_successfully(): void
    {
        $password = 'password123';

        $user = User::factory()->create([
            'password' => bcrypt($password),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => $password,
        ]);

        $response
            ->assertStatus(200)
            ->assertJsonStructure([
                'token',
                'user',
                'needs_verification',
            ]);
    }

    /** @test */
    public function test_login_fails_with_wrong_password(): void
    {
        $user = User::factory()->create([
            'password' => bcrypt('password123'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'passwordSalah',
        ]);

        $response
            ->assertStatus(401)
            ->assertJson([
                'message' => 'Email atau password salah',
            ]);
    }

    /** @test */
    public function test_login_fails_if_email_not_registered(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'tidakada@example.com',
            'password' => 'password123',
        ]);

        $response
            ->assertStatus(401)
            ->assertJson([
                'message' => 'Email atau password salah',
            ]);
    }

    /** @test */
    public function test_guest_cannot_access_user_endpoint(): void
    {
        $response = $this->getJson('/api/user');

        $response->assertStatus(401);
    }
}