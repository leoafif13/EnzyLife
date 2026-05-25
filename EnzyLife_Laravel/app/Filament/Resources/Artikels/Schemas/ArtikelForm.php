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

                Forms\Components\Textarea::make('isi_konten')
                    ->label('Isi Konten')
                    ->required(),

                Forms\Components\FileUpload::make('gambar')
                    ->image()
                    ->label('Gambar Artikel')
                    ->required()
                    ->disk('public')
                    ->visibility('public')
                    ->directory('artikels')
                    ->acceptedFileTypes([
                        'image/jpeg',
                        'image/png',
                    ]),
                
                Forms\Components\DatePicker::make('tanggal_unggah')
                    ->label('Tanggal Unggah')
                    ->default(now())
                    ->required(),
            ]);
    }
}
