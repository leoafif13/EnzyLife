<?php

namespace App\Filament\Resources\Ulasans\Pages;

use App\Filament\Resources\Ulasans\UlasanResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewUlasan extends ViewRecord
{
    protected static string $resource = UlasanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
