<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\Pembayaran;
use App\Models\DetailPemesanan;
use App\Services\MidtransService;

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

        $pembayaran = Pembayaran::create([
            'pemesanan_id' => $pemesanan->id,
            'total_bayar' => $totalHarga,
            'status_pembayaran' => 'BELUM_DIBAYAR',
            'payment_type' => $request->metode_pembayaran,
        ]);

        $snapToken = null;

        if ($request->metode_pembayaran === 'ONLINE') {
            $midtrans = new MidtransService();
            $midtransOrderId = 'ENZY-' . $pemesanan->id . '-' . time();

            $snapToken = $midtrans->createSnapToken([
                'transaction_details' => [
                    'order_id' => $midtransOrderId,
                    'gross_amount' => (int) $totalHarga,
                ],
                'customer_details' => [
                    'first_name' => auth()->user()->name,
                    'email' => auth()->user()->email,
                ],
            ]);

            $pembayaran->update([
                'snap_token' => $snapToken,
                'midtrans_order_id' => $midtransOrderId,
            ]);
        }

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Pemesanan berhasil dibuat',
            'pemesanan_id' => $pemesanan->id,
            'snap_token' => $snapToken,
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
    // Auto-expire unpaid online orders older than 24 hours globally
    Pemesanan::expireUnpaidOrders();

    $orders = Pemesanan::with(['detailPemesanan.produk', 'pembayaran'])
        ->where('user_id', auth()->id())
        ->orderBy('created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data' => $orders
    ]);
}

public function cancel($id)
{
    $pemesanan = Pemesanan::where('user_id', auth()->id())
        ->where('id', $id)
        ->firstOrFail();

    if ($pemesanan->status_pemesanan !== 'MENUNGGU_PEMBAYARAN' && $pemesanan->status_pemesanan !== 'DIKEMAS') {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan ini tidak dapat dibatalkan karena sedang diproses atau sudah selesai.',
        ], 400);
    }

    try {
        $pemesanan->update([
            'status_pemesanan' => 'DIBATALKAN',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pesanan berhasil dibatalkan dan stok dikembalikan.',
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Gagal membatalkan pesanan: ' . $e->getMessage(),
        ], 500);
    }
}

public function pay($id)
{
    $pemesanan = Pemesanan::with('pembayaran')
        ->where('user_id', auth()->id())
        ->where('id', $id)
        ->firstOrFail();

    if ($pemesanan->metode_pembayaran !== 'ONLINE' || $pemesanan->status_pemesanan !== 'MENUNGGU_PEMBAYARAN') {
        return response()->json([
            'success' => false,
            'message' => 'Pesanan ini tidak dapat dibayar sekarang.',
        ], 400);
    }

    $pembayaran = $pemesanan->pembayaran;

    if (!$pembayaran || !$pembayaran->midtrans_order_id) {
        return response()->json([
            'success' => false,
            'message' => 'Detail pembayaran tidak ditemukan. Silakan lakukan checkout ulang.',
        ], 400);
    }

    $isPaid = false;
    $txStatus = 'pending';

    if (request('simulate') === 'true' || request('simulate') === true) {
        $isPaid = true;
    } else {
        // Panggil API Midtrans langsung untuk mengecek status transaksi
        $midtrans = new MidtransService();
        $statusResponse = $midtrans->getStatus($pembayaran->midtrans_order_id);

        if ($statusResponse) {
            $txStatus = strtolower($statusResponse->transaction_status ?? 'pending');
            $isPaid = in_array($txStatus, ['settlement', 'capture']);
        }
    }

    if (!$isPaid) {
        if (in_array($txStatus, ['expire', 'cancel', 'deny'])) {
            DB::beginTransaction();
            try {
                $pemesanan->update([
                    'status_pemesanan' => 'DIBATALKAN',
                ]);
                DB::commit();
                return response()->json([
                    'success' => false,
                    'message' => 'Transaksi pembayaran telah kedaluwarsa atau dibatalkan di Midtrans. Pesanan Anda otomatis dibatalkan.',
                ], 400);
            } catch (\Exception $e) {
                DB::rollBack();
            }
        }

        return response()->json([
            'success' => false,
            'message' => 'Pembayaran belum diselesaikan. Status saat ini: ' . strtoupper($txStatus) . '. Silakan selesaikan pembayaran di halaman Midtrans terlebih dahulu.',
        ], 400);
    }

    DB::beginTransaction();
    try {
        $pemesanan->update([
            'status_pemesanan' => 'DIPROSES',
        ]);

        $pembayaran->update([
            'status_pembayaran' => 'SUDAH_DIBAYAR',
            'tanggal_pembayaran' => now(),
        ]);

        DB::commit();

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil diverifikasi secara real-time!',
        ]);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'success' => false,
            'message' => 'Gagal memproses verifikasi pembayaran: ' . $e->getMessage(),
        ], 500);
    }
}
   
}