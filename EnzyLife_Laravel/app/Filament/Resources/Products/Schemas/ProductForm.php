<?php

namespace App\Filament\Resources\Products\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms;

class ProductForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Forms\Components\TextInput::make('nama')
                    ->label('Nama Produk')
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('harga')

                    ->label('Harga')
                    ->numeric()
                    ->prefix('Rp')
                    ->required(),

                Forms\Components\Textarea::make('deskripsi')
                    ->label('Deskripsi Produk')
                    ->required()
                    ->maxLength(255),

                Forms\Components\TextInput::make('stok')
                    ->label('Jumlah Stok')
                    ->numeric()
                    ->required(),

                Forms\Components\FileUpload::make('gambar')
                    ->image()
                    ->label('Gambar')
                    ->required()
                    ->disk('public')
                    ->visibility('public')
                    ->directory('produk'),
            ]);
    }
}