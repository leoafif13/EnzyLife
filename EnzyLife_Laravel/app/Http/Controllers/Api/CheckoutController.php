<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\Pembayaran;
use App\Models\DetailPemesanan;

class CheckoutController extends Controller
{
    public function checkout(Request $request)
{
    $request->validate([
        'items' => 'required|array|min:1',
        'items.*.produk_id' => 'required|exists:products,id',
        'items.*.qty' => 'required|integer|min:1',

        'metode_pembayaran' => 'required|in:COD,ONLINE',
        'jenis_cod' => 'nullable|in:AMBIL_TEMPAT,BAYAR_DI_RUMAH',
    ]);

    DB::beginTransaction();

    try {

        $totalHarga = 0;

        foreach ($request->items as $item) {

            $produk = Product::findOrFail($item['produk_id']);

            if ($produk->stok < $item['qty']) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Stok produk ' . $produk->nama . ' tidak mencukupi (Tersedia: ' . $produk->stok . ')',
                ], 400);
            }

            $totalHarga += $produk->harga * $item['qty'];
        }

        $pemesanan = Pemesanan::create([
            'user_id' => auth()->id(),
            'total_harga' => $totalHarga,
            'metode_pembayaran' => $request->metode_pembayaran,
            'jenis_cod' => $request->jenis_cod,
            'status_pemesanan' => $request->metode_pembayaran === 'COD' ? 'DIKEMAS' : 'MENUNGGU_PEMBAYARAN',
            'tanggal_pemesanan' => now(),
        ]);

        foreach ($request->items as $item) {

            $produk = Product::findOrFail($item['produk_id']);

            $produk->decrement('stok', $item['qty']);

            DetailPemesanan::create([
                'pemesanan_id' => $pemesanan->id,
                'produk_id' => $produk->id,
                'kuantitas' => $item['qty'],
                'harga' => $produk->harga,
                'subtotal' => $produk->harga * $item['qty'],
            ]);
        }

        Pembayaran::create([
            'pemesanan_id' => $pemesanan->id,
            'total_bayar' => $totalHarga,
            'status_pembayaran' => 'BELUM_DIBAYAR',
        ]);

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Pemesanan berhasil dibuat',
            'pemesanan_id' => $pemesanan->id,
        ]);

    } catch (\Exception $e) {

        DB::rollBack();

        return response()->json([
            'success' => false,
            'message' => $e->getMessage(),
        ], 500);
    }
}

public function history()
{
    $orders = Pemesanan::with(['detailPemesanan.produk', 'pembayaran'])
        ->where('user_id', auth()->id())
        ->orderBy('created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $orders
    ]);
}

public function pay($id)
{
    $pemesanan = Pemesanan::where('user_id', auth()->id())
        ->where('id', $id)
        ->firstOrFail();

    if ($pemesanan->metode_pembayaran !== 'ONLINE' || $pemesanan->status_pemesanan !== 'MENUNGGU_PEMBAYARAN') {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan ini tidak dapat dibayar sekarang.',
        ], 400);
    }

    DB::beginTransaction();
    try {
        $pemesanan->update([
            'status_pemesanan' => 'DIKEMAS',
        ]);

        if ($pemesanan->pembayaran) {
            $pemesanan->pembayaran->update([
                'status_pembayaran' => 'SUDAH_DIBAYAR',
                'tanggal_pembayaran' => now(),
            ]);
        }

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil dikonfirmasi',
        ]);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => 'Gagal memproses pembayaran: ' . $e->getMessage(),
        ], 500);
    }
}
   
}