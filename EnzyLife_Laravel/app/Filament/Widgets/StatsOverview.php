<?php

namespace App\Filament\Widgets;

use App\Models\Product;
use App\Models\Pemesanan;
use App\Models\Pembayaran;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make(
                'Total Produk',
                Product::count()
            ),

            Stat::make(
                'Total Pesanan',
                Pemesanan::count()
            ),

            Stat::make(
                'Pesanan Selesai',
                Pemesanan::where('status_pemesanan', 'SELESAI')->count()
            ),

            Stat::make(
                'Total Penjualan',
                'Rp ' . number_format(
                    Pembayaran::where('status_pembayaran', 'SUDAH_DIBAYAR')
                        ->sum('total_bayar'),
                    0,
                    ',',
                    '.'
                )
            ),
        ];
    }
}