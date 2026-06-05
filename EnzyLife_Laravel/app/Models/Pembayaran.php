<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pembayaran extends Model
{
    protected $table = 'pembayaran';

    protected $fillable = [
        'pemesanan_id',
        'total_bayar',
        'payment_type',
        'midtrans_order_id',
        'status_pembayaran',
        'tanggal_pembayaran',
    ];

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }
}