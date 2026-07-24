<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Mail;
use App\Mail\SendOTPMail;

class RegistrationTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function test_user_can_register_successfully(): void
    {
        Mail::fake();

        $response = $this->postJson('/api/register', [
            'name' => 'Leo',
            'email' => 'leo@test.com',
            'password' => 'password123',
        ]);

        $response
            ->assertStatus(200)
            ->assertJsonStructure([
                'token',
                'user',
                'needs_verification',
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'leo@test.com',
        ]);

        Mail::assertSent(SendOTPMail::class);
    }

    /** @test */
    public function test_registration_fails_when_email_is_already_registered(): void
    {
        User::factory()->create([
            'email' => 'leo@test.com',
        ]);

        $response = $this->postJson('/api/register', [
            'name' => 'Leo',
            'email' => 'leo@test.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(422);
    }

    /** @test */
    public function test_registration_fails_when_password_is_less_than_8_characters(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Leo',
            'email' => 'leo@test.com',
            'password' => '1234567',
        ]);

        $response->assertStatus(422);
    }
}