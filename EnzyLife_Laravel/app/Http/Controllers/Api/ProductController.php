<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // GET ALL PRODUCTS
    public function index(Request $request)
    {
        $perPage = $request->query('per_page');
        $sortBy = $request->query('sort_by', 'default'); // 'default', 'sales', or 'price'
        $sortOrder = $request->query('sort_order', 'desc'); // 'asc' or 'desc'
        $search = $request->query('search');
        $rating = $request->query('rating');

        $query = Product::withSum('detailPemesanan as sales_count', 'kuantitas')
            ->withAvg('reviews as rating_avg', 'rating')
            ->withCount('reviews as rating_count');

        // Apply search filter
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('nama', 'like', "%{$search}%")
                  ->orWhere('deskripsi', 'like', "%{$search}%");
            });
        }

        // Apply rating filter
        if ($rating) {
            $query->whereRaw('(SELECT AVG(rating) FROM reviews WHERE reviews.produk_id = products.id) >= ?', [$rating]);
        }

        // 1. Stock = 0 goes to the bottom
        $query->orderByRaw('CASE WHEN stok = 0 THEN 1 ELSE 0 END ASC');

        // 2. Sort by price, sales_count, rating, or default (created_at/id) with multi-sort support
        $sortFields = explode(',', $sortBy);
        $sortDirections = explode(',', $sortOrder);

        for ($i = 0; $i < count($sortFields); $i++) {
            $field = trim($sortFields[$i]);
            $dir = isset($sortDirections[$i]) ? trim($sortDirections[$i]) : (isset($sortDirections[0]) ? trim($sortDirections[0]) : 'desc');
            $dir = strtolower($dir) === 'asc' ? 'asc' : 'desc';

            if ($field === 'price') {
                $query->orderBy('harga', $dir);
            } elseif ($field === 'sales') {
                $query->orderBy('sales_count', $dir);
            } elseif ($field === 'rating') {
                $query->orderByRaw('CASE WHEN rating_avg IS NULL THEN 1 ELSE 0 END ASC');
                $query->orderBy('rating_avg', $dir);
            } elseif ($field === 'default') {
                $query->orderBy('id', $dir);
            }
        }

        // Always fallback to id desc for consistent pagination
        $query->orderBy('id', 'desc');

        if ($perPage) {
            $products = $query->paginate((int) $perPage);
            
            $products->getCollection()->transform(function ($product) {
                $product->sales_count = (int) ($product->sales_count ?? 0);
                $product->rating_avg = round((float) ($product->rating_avg ?? 0.0), 1);
                $product->rating_count = (int) ($product->rating_count ?? 0);
                return $product;
            });
        } else {
            $products = $query->get()->map(function ($product) {
                $product->sales_count = (int) ($product->sales_count ?? 0);
                $product->rating_avg = round((float) ($product->rating_avg ?? 0.0), 1);
                $product->rating_count = (int) ($product->rating_count ?? 0);
                return $product;
            });
        }

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
            'deskripsi' => 'required|min:150|max:255',
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
        $product = Product::withSum('detailPemesanan as sales_count', 'kuantitas')
            ->withAvg('reviews as rating_avg', 'rating')
            ->withCount('reviews as rating_count')
            ->find($id);

        if (!$product) {
            return response()->json([
                'status' => false,
                'message' => 'Product tidak ditemukan'
            ], 404);
        }

        $product->sales_count = (int) ($product->sales_count ?? 0);
        $product->rating_avg = round((float) ($product->rating_avg ?? 0.0), 1);
        $product->rating_count = (int) ($product->rating_count ?? 0);

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
            'deskripsi' => 'required|min:30|max:255',
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