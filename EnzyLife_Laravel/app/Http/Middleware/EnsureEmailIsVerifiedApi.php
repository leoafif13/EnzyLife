<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureEmailIsVerifiedApi
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || !$request->user()->email_verified_at) {
            return response()->json([
                'success' => false,
                'message' => 'Email Anda belum diverifikasi.',
                'needs_verification' => true,
            ], 403);
        }

        return $next($request);
    }
}
