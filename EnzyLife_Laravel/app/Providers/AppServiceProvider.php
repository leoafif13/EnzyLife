<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        try {
            if (config('database.default') && \Illuminate\Support\Facades\Schema::hasTable('pemesanan')) {
                \App\Models\Pemesanan::expireUnpaidOrders();
            }
        } catch (\Exception $e) {
            // Silence database exceptions during migration/setup
        }
    }
}
