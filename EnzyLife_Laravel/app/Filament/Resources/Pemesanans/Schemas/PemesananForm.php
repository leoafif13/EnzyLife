<?php

namespace App\Filament\Resources\Pemesanans\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\Select;

class PemesananForm
{
    public static function configure(Schema $schema): Schema
    {
       return $schema
    ->components([
        Select::make('status_pemesanan')
            ->options([
                'MENUNGGU_PEMBAYARAN' => 'Menunggu Pembayaran',
                'DIPROSES' => 'Diproses',
                'DIKEMAS' => 'Dikemas',
                'DIKIRIM' => 'Dikirim',
                'SIAP_DIAMBIL' => 'Siap Diambil',
                'SELESAI' => 'Selesai',
                'DIBATALKAN' => 'Dibatalkan',
            ])
            ->required(),
    ]);
    }
}
