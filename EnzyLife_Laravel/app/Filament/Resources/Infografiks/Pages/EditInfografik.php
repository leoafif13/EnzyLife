<?php

namespace App\Filament\Resources\Infografiks\Pages;

use App\Filament\Resources\Infografiks\InfografikResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditInfografik extends EditRecord
{
    protected static string $resource = InfografikResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
