<?php

namespace App\Filament\Resources\Infografiks\Pages;

use App\Filament\Resources\Infografiks\InfografikResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListInfografiks extends ListRecords
{
    protected static string $resource = InfografikResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
