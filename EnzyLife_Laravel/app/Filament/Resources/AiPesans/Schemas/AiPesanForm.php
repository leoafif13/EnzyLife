<?php

namespace App\Filament\Resources\AiPesans\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class AiPesanForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('id_percakapan')
                    ->required()
                    ->numeric(),
                Select::make('peran')
                    ->options(['user' => 'User', 'assistant' => 'Assistant'])
                    ->required(),
                Textarea::make('isi')
                    ->required()
                    ->columnSpanFull(),
            ]);
    }
}
