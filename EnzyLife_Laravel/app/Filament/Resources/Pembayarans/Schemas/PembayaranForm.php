<?php

namespace App\Filament\Resources\Pembayarans\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms\Components\TextInput;

class PembayaranForm
{
    public static function configure(Schema $schema): Schema
    {
       return $schema
        ->components([
            TextInput::make('status_pembayaran')
                ->disabled(),

            TextInput::make('pemesanan.metode_pembayaran')
                ->label('Metode Pembayaran')
                ->disabled(),

            TextInput::make('midtrans_order_id')
                ->disabled(),
        ]);
    }
}
