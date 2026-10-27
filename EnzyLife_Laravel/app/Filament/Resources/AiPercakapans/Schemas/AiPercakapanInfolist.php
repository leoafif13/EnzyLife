<?php

namespace App\Filament\Resources\AiPercakapans\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class AiPercakapanInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('id_pelanggan')
                    ->numeric(),
                TextEntry::make('judul'),
                IconEntry::make('disimpan')
                    ->boolean(),
                TextEntry::make('feedback')
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
