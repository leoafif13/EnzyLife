<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use App\Mail\SendOTPMail;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau password salah'
            ], 401);
        }

        $token = $user->createToken('flutter-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $user,
            'needs_verification' => $user->email_verified_at === null,
        ]);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name'     => 'required|string',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:8',
        ]);

        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
        ]);

        // Generate OTP
        $otp = rand(100000, 999999);
        Cache::put('email_verification_otp_' . $user->email, $otp, now()->addMinutes(15));

        // Send Email
        try {
            Mail::to($user->email)->send(new SendOTPMail($otp, 'verification'));
        } catch (\Exception $e) {
            Log::error('Gagal mengirim email verifikasi: ' . $e->getMessage());
        }

        $token = $user->createToken('flutter-app')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user'  => $user,
            'needs_verification' => true,
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }

    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    public function verifyEmail(Request $request)
    {
        $request->validate([
            'otp' => 'required|string|size:6',
        ]);

        $user = $request->user();
        $cachedOtp = Cache::get('email_verification_otp_' . $user->email);

        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP tidak valid atau telah kedaluwarsa.',
            ], 400);
        }

        $user->forceFill([
            'email_verified_at' => now(),
        ])->save();

        Cache::forget('email_verification_otp_' . $user->email);

        return response()->json([
            'success' => true,
            'message' => 'Email Anda berhasil diverifikasi.',
            'user' => $user,
        ]);
    }

    public function resendVerificationOtp(Request $request)
    {
        $user = $request->user();

        if ($user->email_verified_at) {
            return response()->json([
                'success' => false,
                'message' => 'Email Anda sudah terverifikasi.',
            ], 400);
        }

        $otp = rand(100000, 999999);
        Cache::put('email_verification_otp_' . $user->email, $otp, now()->addMinutes(15));

        try {
            Mail::to($user->email)->send(new SendOTPMail($otp, 'verification'));
        } catch (\Exception $e) {
            Log::error('Gagal mengirim ulang email verifikasi: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim email verifikasi. Silakan coba beberapa saat lagi.',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP verifikasi baru telah dikirim ke email Anda.',
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
        ]);

        $otp = rand(100000, 999999);
        Cache::put('password_reset_otp_' . $request->email, $otp, now()->addMinutes(15));

        try {
            Mail::to($request->email)->send(new SendOTPMail($otp, 'reset'));
        } catch (\Exception $e) {
            Log::error('Gagal mengirim email reset password: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim email reset password. Silakan coba beberapa saat lagi.',
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'Kode OTP untuk reset password telah dikirim ke email Anda.',
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'otp' => 'required|string|size:6',
            'password' => 'required|min:8|confirmed',
        ]);

        $cachedOtp = Cache::get('password_reset_otp_' . $request->email);

        if (!$cachedOtp || $cachedOtp != $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP tidak valid atau telah kedaluwarsa.',
            ], 400);
        }

        $user = User::where('email', $request->email)->firstOrFail();
        $user->forceFill([
            'password' => Hash::make($request->password),
        ])->save();

        Cache::forget('password_reset_otp_' . $request->email);

        return response()->json([
            'success' => true,
            'message' => 'Password Anda berhasil diperbarui. Silakan login kembali.',
        ]);
    }

    public function loginGoogle(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
        ]);

        $token = $request->id_token;

        try {
            // Coba verifikasi sebagai id_token dahulu
            $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                'id_token' => $token,
            ]);

            // Jika gagal, coba verifikasi sebagai access_token
            if ($response->failed()) {
                $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
                    'access_token' => $token,
                ]);
            }

            if ($response->failed()) {
                return response()->json([
                    'message' => 'Token Google tidak valid atau kedaluwarsa'
                ], 400);
            }

            $payload = $response->json();

            if (!isset($payload['email'])) {
                return response()->json([
                    'message' => 'Token tidak memiliki informasi email'
                ], 400);
            }

            $email = $payload['email'];
            $name = $payload['name'] ?? explode('@', $email)[0];

            $user = User::where('email', $email)->first();

            if (!$user) {
                $user = User::create([
                    'name' => $name,
                    'email' => $email,
                    'password' => Hash::make(Str::random(24)),
                    'email_verified_at' => now(),
                ]);
            } else {
                if ($user->email_verified_at === null) {
                    $user->email_verified_at = now();
                    $user->save();
                }
            }

            $token = $user->createToken('flutter-app')->plainTextToken;

            return response()->json([
                'token' => $token,
                'user'  => $user,
                'needs_verification' => false,
            ]);

        } catch (\Exception $e) {
            Log::error('Error saat login Google: ' . $e->getMessage());
            return response()->json([
                'message' => 'Gagal memproses login Google'
            ], 500);
        }
    }
}