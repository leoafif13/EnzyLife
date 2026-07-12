<?php

namespace App\Filament\Resources\Products\Schemas;

use Filament\Schemas\Schema;
use Filament\Schemas\Components\Section;
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
                    ->minLength(30)
                    ->maxLength(255)
                    ->helperText('Minimal 30 karakter agar informasi produk cukup jelas.'),

                Section::make('Spesifikasi Detail Produk')
                    ->description('Masukkan spesifikasi khusus untuk produk ini.')
                    ->schema([
                        Forms\Components\TextInput::make('spesifikasi.Volume')
                            ->label('Volume')
                            ->placeholder('e.g. 500 ml')
                            ->nullable(),
                        Forms\Components\TextInput::make('spesifikasi.Bahan')
                            ->label('Bahan Utama')
                            ->placeholder('e.g. Kulit Jeruk, Air, Molase')
                            ->nullable(),
                        Forms\Components\TextInput::make('spesifikasi.Lama Fermentasi')
                            ->label('Lama Fermentasi')
                            ->placeholder('e.g. 3 Bulan')
                            ->nullable(),
                        Forms\Components\TextInput::make('spesifikasi.Masa Simpan')
                            ->label('Masa Simpan')
                            ->placeholder('e.g. 12 Bulan')
                            ->nullable(),
                    ])
                    ->columns(2),

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
                    ->directory('produk')
                    ->acceptedFileTypes([
                        'image/jpeg',
                        'image/png',
                    ]),
            ]);
    }
}