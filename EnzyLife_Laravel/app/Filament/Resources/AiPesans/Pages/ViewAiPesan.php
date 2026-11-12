<?php

namespace App\Filament\Resources\AiPesans\Pages;

use App\Filament\Resources\AiPesans\AiPesanResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewAiPesan extends ViewRecord
{
    protected static string $resource = AiPesanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // EditAction::make(),
        ];
    }
}
