<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ArtikelController;
use App\Http\Controllers\Api\InfografikController;
use App\Http\Controllers\Api\ProfileController;
use App\Http\Controllers\Api\CheckoutController;
use App\Http\Controllers\Api\ReviewController;


Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/password/forgot', [AuthController::class, 'forgotPassword']);
Route::post('/password/reset', [AuthController::class, 'resetPassword']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/email/verify', [AuthController::class, 'verifyEmail']);
    Route::post('/email/resend', [AuthController::class, 'resendVerificationOtp']);

    Route::middleware('verified.api')->group(function () {
        Route::apiResource('products', ProductController::class);

        Route::get('/artikel', [ArtikelController::class, 'index']);
        Route::get('/artikel/{id}', [ArtikelController::class, 'show']);

        Route::get('/infografik', [InfografikController::class, 'index']);
        Route::get('/infografik/{id}', [InfografikController::class, 'show']);

        Route::get('/profile', [ProfileController::class, 'show']);
        Route::put('/profile', [ProfileController::class, 'update']);

        Route::post('/checkout', [CheckoutController::class, 'checkout']);
        Route::get('/orders', [CheckoutController::class, 'history']);
        Route::post('/orders/{id}/pay', [CheckoutController::class, 'pay']);
        Route::post('/orders/{id}/cancel', [CheckoutController::class, 'cancel']);

        Route::post('/review', [ReviewController::class, 'store']);
        Route::get('/produk/{produk}/sentiment', [ReviewController::class, 'sentimentByProduct']);
        Route::get('/produk/{produk}/review-summary', [ReviewController::class, 'reviewSummary']);
    });
});



    

