<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Pembayaran extends Model
{
    use HasFactory;
    protected $table = 'pembayaran';

    protected $fillable = [
        'pemesanan_id',
        'total_bayar',
        'payment_type',
        'midtrans_order_id',
        'snap_token',
        'status_pembayaran',
        'tanggal_pembayaran',
    ];

    protected static function booted()
    {
        static::updating(function ($pembayaran) {
            if ($pembayaran->isDirty('status_pembayaran') && $pembayaran->status_pembayaran === 'SUDAH_DIBAYAR') {
                $pembayaran->tanggal_pembayaran = now();
            }
        });

        static::updated(function ($pembayaran) {
            if ($pembayaran->wasChanged('status_pembayaran')) {
                if ($pembayaran->status_pembayaran === 'SUDAH_DIBAYAR') {
                    $pemesanan = $pembayaran->pemesanan;
                    if ($pemesanan) {
                        if ($pemesanan->metode_pembayaran === 'COD') {
                            $pemesanan->update([
                                'status_pemesanan' => 'SELESAI',
                            ]);
                        } elseif ($pemesanan->metode_pembayaran === 'ONLINE' && $pemesanan->status_pemesanan === 'MENUNGGU_PEMBAYARAN') {
                            $pemesanan->update([
                                'status_pemesanan' => 'DIPROSES',
                            ]);
                        }
                    }
                } elseif ($pembayaran->status_pembayaran === 'CANCEL') {
                    $pemesanan = $pembayaran->pemesanan;
                    if ($pemesanan && $pemesanan->status_pemesanan !== 'DIBATALKAN') {
                        $pemesanan->update([
                            'status_pemesanan' => 'DIBATALKAN',
                        ]);
                    }
                }
            }
        });
    }

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }
}