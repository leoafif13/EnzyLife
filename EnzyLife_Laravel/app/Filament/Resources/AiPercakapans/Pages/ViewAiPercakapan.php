<?php

namespace App\Filament\Resources\AiPercakapans\Pages;

use App\Filament\Resources\AiPercakapans\AiPercakapanResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewAiPercakapan extends ViewRecord
{
    protected static string $resource = AiPercakapanResource::class;

    protected function getHeaderActions(): array
    {
        return [
           //
        ];
    }
}
