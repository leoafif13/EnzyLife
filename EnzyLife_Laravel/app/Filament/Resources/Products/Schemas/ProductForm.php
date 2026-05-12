<?php

namespace App\Filament\Resources\Products\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Schemas\Schema;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('nama')
                    ->label('Nama Produk')
                    ->required()
                    ->maxLength(255),

                TextInput::make('harga')
                    ->label('Harga')
                    ->numeric()
                    ->prefix('Rp')
                    ->required(),

                TextInput::make('deskripsi')
                    ->label('Deskripsi Produk')
                    ->required()
                    ->maxLength(255),

                TextInput::make('stok')
                    ->label('Jumlah Stok')
                    ->numeric()
                    ->required(),

                TextInput::make('gambar')
                    ->label('Gambar')
                    ->required()
                    ->maxLength(255),

            ]);
    }
}