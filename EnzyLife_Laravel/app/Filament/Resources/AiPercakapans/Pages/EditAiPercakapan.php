<?php

namespace App\Filament\Resources\AiPercakapans\Pages;

use App\Filament\Resources\AiPercakapans\AiPercakapanResource;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Resources\Pages\EditRecord;

class EditAiPercakapan extends EditRecord
{
    protected static string $resource = AiPercakapanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
