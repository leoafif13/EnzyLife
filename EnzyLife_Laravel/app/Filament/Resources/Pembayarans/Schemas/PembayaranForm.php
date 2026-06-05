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

            TextInput::make('payment_type')
                ->disabled(),

            TextInput::make('midtrans_order_id')
                ->disabled(),
        ]);
    }
}
