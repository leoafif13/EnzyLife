<?php

namespace App\Filament\Resources\Infografiks\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\FileUpload;
use Filament\Schemas\Schema;

class InfografikForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('judul')
                    ->label('Judul Infografik')
                    ->required()
                    ->maxLength(255),

                Textarea::make('deskripsi')
                    ->label('Deskripsi Infografik')
                    ->required(),

                FileUpload::make('gambar')
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
            ]);
    }
}