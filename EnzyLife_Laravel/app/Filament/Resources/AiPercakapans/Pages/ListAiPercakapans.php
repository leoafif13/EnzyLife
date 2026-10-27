<?php

namespace App\Filament\Resources\AiPercakapans\Pages;

use App\Filament\Resources\AiPercakapans\AiPercakapanResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListAiPercakapans extends ListRecords
{
    protected static string $resource = AiPercakapanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // CreateAction::make(),
        ];
    }
}
