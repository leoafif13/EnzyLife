<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // GET ALL PRODUCTS
    public function index()
    {
        $products = Product::all();

        return response()->json([
            'status' => true,
            'message' => 'Data product berhasil diambil',
            'data' => $products
        ]);
    }

    // INSERT PRODUCT
    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required',
            'harga' => 'required|integer',
            'deskripsi' => 'required',
            'stok' => 'required|integer',
            'gambar' => 'required'
        ]);

        $product = Product::create([
            'nama' => $request->nama,
            'harga' => $request->harga,
            'deskripsi' => $request->deskripsi,
            'stok' => $request->stok,
            'gambar' => $request->gambar,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Product berhasil ditambahkan',
            'data' => $product
        ], 201);
    }

    // GET SINGLE PRODUCT
    public function show($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'status' => false,
                'message' => 'Product tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => true,
            'data' => $product
        ]);
    }

    // UPDATE PRODUCT
    public function update(Request $request, $id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'status' => false,
                'message' => 'Product tidak ditemukan'
            ], 404);
        }

        $request->validate([
            'nama' => 'required',
            'harga' => 'required|integer',
            'deskripsi' => 'required',
            'stok' => 'required|integer',
            'gambar' => 'required'
        ]);

        $product->update([
            'nama' => $request->nama,
            'harga' => $request->harga,
            'deskripsi' => $request->deskripsi,
            'stok' => $request->stok,
            'gambar' => $request->gambar,
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Product berhasil diupdate',
            'data' => $product
        ]);
    }

    // DELETE PRODUCT
    public function destroy($id)
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'status' => false,
                'message' => 'Product tidak ditemukan'
            ], 404);
        }

        $product->delete();

        return response()->json([
            'status' => true,
            'message' => 'Product berhasil dihapus'
        ]);
    }
}