<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    // REGISTER
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:6'
        ]);

        // VALIDASI GAGAL
        if ($validator->fails()) {

            return response()->json([
                'status'  => false,
                'message' => $validator->errors()
            ], 422);
        }

        // SIMPAN USER
        $user = User::create([
            'name'     => $request->name,
            'email'    => $request->email,
            'password' => Hash::make($request->password),
            'role'     => 'user'
        ]);

        // BUAT TOKEN
        $token = $user->createToken('auth_token')->plainTextToken;

        // RESPONSE
        return response()->json([
            'status'  => true,
            'message' => 'Register berhasil',
            'token'   => $token,
            'user'    => $user
        ]);
    }

    // LOGIN
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required'
        ]);

        // CARI USER
        $user = User::where('email', $request->email)->first();

        // CEK USER / PASSWORD
        if (!$user || !Hash::check($request->password, $user->password)) {

            return response()->json([
                'status'  => false,
                'message' => 'Email atau password salah'
            ], 401);
        }

        // BUAT TOKEN
        $token = $user->createToken('auth_token')->plainTextToken;

        // RESPONSE
        return response()->json([
            'status'  => true,
            'message' => 'Login berhasil',
            'token'   => $token,
            'user'    => $user
        ]);
    }

    // LOGOUT
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status'  => true,
            'message' => 'Logout berhasil'
        ]);
    }
}