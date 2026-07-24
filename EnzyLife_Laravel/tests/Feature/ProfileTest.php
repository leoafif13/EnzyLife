<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ProfileTest extends TestCase
{
    use RefreshDatabase;

    protected function authenticatedUser(): User
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
            'password' => bcrypt('password123'),
        ]);

        $this->actingAs($user, 'sanctum');

        return $user;
    }

    public function test_user_can_view_profile(): void
    {
        $user = $this->authenticatedUser();

        $response = $this->getJson('/api/profile');

        $response
            ->assertStatus(200)
            ->assertJson([
                'user' => [
                    'id' => $user->id,
                    'email' => $user->email,
                ],
            ]);
    }

    public function test_user_can_update_profile(): void
    {
        $user = $this->authenticatedUser();

        $response = $this->putJson('/api/profile', [
            'name' => 'Leo Updated',
            'phone' => '081234567890',
            'address' => 'Jalan Ahmad Yani Nomor 123 Batam Kepulauan Riau',
            'postal_code' => '29411',
        ]);

        $response
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Profil berhasil diperbarui',
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'Leo Updated',
            'phone' => '081234567890',
            'postal_code' => '29411',
        ]);
    }

    public function test_user_can_update_password(): void
    {
        $user = $this->authenticatedUser();

        $response = $this->putJson('/api/profile/password', [
            'current_password' => 'password123',
            'password' => 'passwordBaru123',
            'password_confirmation' => 'passwordBaru123',
        ]);

        $response
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Password berhasil diperbarui.',
            ]);

        $user->refresh();

        $this->assertTrue(
            Hash::check('passwordBaru123', $user->password)
        );
    }

    public function test_user_cannot_update_password_with_wrong_current_password(): void
    {
        $this->authenticatedUser();

        $response = $this->putJson('/api/profile/password', [
            'current_password' => 'passwordSalah',
            'password' => 'passwordBaru123',
            'password_confirmation' => 'passwordBaru123',
        ]);

        $response
            ->assertStatus(400)
            ->assertJson([
                'message' => 'Password lama salah.',
            ]);
    }

    public function test_guest_cannot_access_profile(): void
    {
        $response = $this->getJson('/api/profile');

        $response->assertStatus(401);
    }
}