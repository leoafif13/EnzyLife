<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Pemesanan extends Model
{
    use HasFactory;
    protected $table = 'pemesanan';

    protected $fillable = [
        'user_id',
        'total_harga',
        'metode_pembayaran',
        'jenis_cod',
        'status_pemesanan',
        'tanggal_pemesanan',
    ];

    protected static function booted()
    {
        static::updated(function ($pemesanan) {
            if ($pemesanan->wasChanged('status_pemesanan') && $pemesanan->status_pemesanan === 'DIBATALKAN') {
                // 1. Cancel payment if exists
                if ($pemesanan->pembayaran && $pemesanan->pembayaran->status_pembayaran !== 'CANCEL') {
                    $pemesanan->pembayaran->update([
                        'status_pembayaran' => 'CANCEL',
                    ]);
                }

                // 2. Return product stock
                foreach ($pemesanan->detailPemesanan as $detail) {
                    $produk = $detail->produk;
                    if ($produk) {
                        $produk->increment('stok', $detail->kuantitas);
                    }
                }
            }
        });
    }

    public static function expireUnpaidOrders()
    {
        try {
            $pendingOrders = self::where('metode_pembayaran', 'ONLINE')
                ->where('status_pemesanan', 'MENUNGGU_PEMBAYARAN')
                ->with('pembayaran')
                ->get();

            $midtrans = new \App\Services\MidtransService();

            foreach ($pendingOrders as $pemesanan) {
                // If it is older than 24 hours, automatically cancel it directly
                if ($pemesanan->created_at->lt(now()->subDay())) {
                    $pemesanan->update([
                        'status_pemesanan' => 'DIBATALKAN',
                    ]);
                    continue;
                }

                // Otherwise, check status in real-time on Midtrans sandbox
                $pembayaran = $pemesanan->pembayaran;
                if ($pembayaran && $pembayaran->midtrans_order_id) {
                    $statusResponse = $midtrans->getStatus($pembayaran->midtrans_order_id);
                    if ($statusResponse) {
                        $txStatus = strtolower($statusResponse->transaction_status ?? 'pending');
                        if (in_array($txStatus, ['expire', 'cancel', 'deny'])) {
                            $pemesanan->update([
                                'status_pemesanan' => 'DIBATALKAN',
                            ]);
                        }
                    }
                }
            }
        } catch (\Exception $e) {
            // Silence DB exceptions during migration/setup
        }
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function detailPemesanan()
    {
        return $this->hasMany(DetailPemesanan::class);
    }

    public function pembayaran()
    {
        return $this->hasOne(Pembayaran::class);
    }

    public function review()
    {
        return $this->hasOne(Review::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }
}