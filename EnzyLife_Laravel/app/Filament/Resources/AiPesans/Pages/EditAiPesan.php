<?php

namespace App\Filament\Resources\AiPesans\Pages;

use App\Filament\Resources\AiPesans\AiPesanResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditAiPesan extends EditRecord
{
    protected static string $resource = AiPesanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            DeleteAction::make(),
        ];
    }
}
