<?php

namespace App\Filament\Resources\Infografiks\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class InfografikForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Forms\Components\TextInput::make('judul')
                    ->label('Judul Infografik')
                    ->required()
                    ->maxLength(255),

                Forms\Components\Textarea::make('deskripsi')
                    ->label('Deskripsi Infografik')
                    ->required(),

                Forms\Components\FileUpload::make('gambar')
                    ->image()
                    ->label('Gambar Infografik')
                    ->required()
                    ->disk('public')
                    ->visibility('public')
                    ->directory('infografik')
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
