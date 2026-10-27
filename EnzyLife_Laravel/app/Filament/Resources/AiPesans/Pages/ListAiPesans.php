<?php

namespace App\Filament\Resources\AiPesans\Pages;

use App\Filament\Resources\AiPesans\AiPesanResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListAiPesans extends ListRecords
{
    protected static string $resource = AiPesanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // CreateAction::make(),
        ];
    }
}
