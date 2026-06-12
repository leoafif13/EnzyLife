<?php

namespace App\Filament\Resources\Ulasans\Pages;

use App\Filament\Resources\Ulasans\UlasanResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListUlasans extends ListRecords
{
    protected static string $resource = UlasanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // CreateAction::make(),
        ];
    }
}
