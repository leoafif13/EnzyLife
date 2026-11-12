<?php

namespace App\Filament\Resources\AiPercakapans;

use App\Filament\Resources\AiPercakapans\Pages\CreateAiPercakapan;
use App\Filament\Resources\AiPercakapans\Pages\EditAiPercakapan;
use App\Filament\Resources\AiPercakapans\Pages\ListAiPercakapans;
use App\Filament\Resources\AiPercakapans\Pages\ViewAiPercakapan;
use App\Filament\Resources\AiPercakapans\Schemas\AiPercakapanForm;
use App\Filament\Resources\AiPercakapans\Schemas\AiPercakapanInfolist;
use App\Filament\Resources\AiPercakapans\Tables\AiPercakapansTable;
use App\Models\AiPercakapan;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class AiPercakapanResource extends Resource
{
    protected static ?string $model = AiPercakapan::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static ?string $recordTitleAttribute = 'AIPercakapan';

    public static function form(Schema $schema): Schema
    {
        return AiPercakapanForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return AiPercakapanInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return AiPercakapansTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListAiPercakapans::route('/'),
        ];
    }
}
