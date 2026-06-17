<?php

namespace App\Filament\Resources\Artikels\Schemas;

use Filament\Schemas\Schema;
use Filament\Forms;

class ArtikelForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([

                Forms\Components\TextInput::make('judul')
                    ->label('Judul Artikel')
                    ->required()
                    ->maxLength(255),

                Forms\Components\Textarea::make('ringkasan')
                    ->label('Ringkasan Artikel')
                    ->rows(3)
                    ->maxLength(500)
                    ->helperText('Ringkasan singkat untuk preview artikel'),

                Forms\Components\Textarea::make('isi_konten')
                    ->label('Isi Konten')
                    ->rows(15)
                    ->required(),

                Forms\Components\FileUpload::make('gambar')
                    ->label('Gambar Artikel')
                    ->image()
                    ->required()
                    ->disk('public')
                    ->visibility('public')
                    ->directory('artikels')
                    ->acceptedFileTypes([
                        'image/jpeg',
                        'image/png',
                        'image/webp',
                    ]),

                Forms\Components\TextInput::make('kategori')
                    ->label('Kategori')
                    ->placeholder('Contoh: Tips, Pertanian, Pengenalan')
                    ->maxLength(100),

                Forms\Components\TextInput::make('tautan')
                    ->label('Tautan / Link Artikel')
                    ->url()
                    ->placeholder('Contoh: https://example.com/artikel')
                    ->maxLength(255),
            ]);
    }
}