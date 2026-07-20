<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Product;
use App\Models\Review;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ReviewSummaryTest extends TestCase
{
    use RefreshDatabase;

    public function test_review_summary_returns_correct_average_rating()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        Review::factory()->count(3)->create([
            'user_id' => $user->id,
            'produk_id' => $produk->id,
            'rating' => 5,
            'sentiment_label' => 'positif',
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson("/api/produk/{$produk->id}/review-summary");

        $response
            ->assertStatus(200)
            ->assertJson([
                'average_rating' => 5.0,
                'total_review' => 3,
            ]);
    }

    public function test_review_summary_returns_correct_sentiment_percentage()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        Review::factory()->count(2)->create([
            'user_id' => $user->id,
            'produk_id' => $produk->id,
            'rating' => 5,
            'sentiment_label' => 'positif',
        ]);

        Review::factory()->create([
            'user_id' => $user->id,
            'produk_id' => $produk->id,
            'rating' => 3,
            'sentiment_label' => 'netral',
        ]);

        Review::factory()->create([
            'user_id' => $user->id,
            'produk_id' => $produk->id,
            'rating' => 1,
            'sentiment_label' => 'negatif',
        ]);

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson("/api/produk/{$produk->id}/review-summary");

        $response
            ->assertStatus(200)
            ->assertJson([
                'positif' => 50.0,
                'netral' => 25.0,
                'negatif' => 25.0,
            ]);
    }

    public function test_review_summary_returns_zero_when_no_review_exists()
    {
        $user = User::factory()->create([
            'email_verified_at' => now(),
        ]);

        $produk = Product::factory()->create();

        $response = $this
            ->actingAs($user, 'sanctum')
            ->getJson("/api/produk/{$produk->id}/review-summary");

        $response
            ->assertStatus(200)
            ->assertJson([
                'average_rating' => 0,
                'total_review' => 0,
                'positif' => 0,
                'netral' => 0,
                'negatif' => 0,
            ]);
    }
}