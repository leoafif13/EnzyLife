<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;

class ChatbotController extends Controller
{
    public function products()
    {
        return Product::select(
            'id',
            'nama',
            'harga',
            'deskripsi'
        )->get();
    }
}
