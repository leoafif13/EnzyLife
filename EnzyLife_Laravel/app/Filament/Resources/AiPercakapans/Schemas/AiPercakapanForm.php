<?php

namespace App\Filament\Resources\AiPercakapans\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class AiPercakapanForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('id_pelanggan')
                    ->required()
                    ->numeric(),
                TextInput::make('judul')
                    ->required()
                    ->default('Percakapan Baru'),
                Toggle::make('disimpan')
                    ->required(),
                TextInput::make('feedback'),
            ]);
    }
}
