<?php

namespace App\Filament\Resources\Ulasans\Pages;

use App\Filament\Resources\Ulasans\UlasanResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditUlasan extends EditRecord
{
    protected static string $resource = UlasanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
