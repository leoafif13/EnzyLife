<?php

namespace Tests\Feature;

use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    protected function authenticatedUser(): User
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $this->actingAs($user, 'sanctum');

        return $user;
    }

    public function test_user_can_view_all_products(): void
    {
        $this->authenticatedUser();

        Product::factory()->count(3)->create();

        $response = $this->getJson('/api/products');

        $response
            ->assertStatus(200)
            ->assertJson([
                'status' => true,
                'message' => 'Data product berhasil diambil',
            ]);

        $this->assertCount(3, $response->json('data'));
    }

    public function test_user_can_view_product_detail(): void
    {
        $this->authenticatedUser();

        $product = Product::factory()->create();

        $response = $this->getJson("/api/products/{$product->id}");

        $response
            ->assertStatus(200)
            ->assertJson([
                'status' => true,
            ]);

        $this->assertEquals(
            $product->id,
            $response->json('data.id')
        );
    }

    public function test_user_cannot_view_nonexistent_product(): void
    {
        $this->authenticatedUser();

        $response = $this->getJson('/api/products/999');

        $response
            ->assertStatus(404)
            ->assertJson([
                'status' => false,
                'message' => 'Product tidak ditemukan',
            ]);
    }

    public function test_guest_cannot_access_products(): void
    {
        $response = $this->getJson('/api/products');

        $response->assertStatus(401);
    }
}