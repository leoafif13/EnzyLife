<?php

namespace App\Filament\Resources\AiPesans;

use App\Filament\Resources\AiPesans\Pages\CreateAiPesan;
use App\Filament\Resources\AiPesans\Pages\EditAiPesan;
use App\Filament\Resources\AiPesans\Pages\ListAiPesans;
use App\Filament\Resources\AiPesans\Pages\ViewAiPesan;
use App\Filament\Resources\AiPesans\Schemas\AiPesanForm;
use App\Filament\Resources\AiPesans\Schemas\AiPesanInfolist;
use App\Filament\Resources\AiPesans\Tables\AiPesansTable;
use App\Models\AiPesan;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class AiPesanResource extends Resource
{
    protected static ?string $model = AiPesan::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static ?string $recordTitleAttribute = 'AIPesan';

    public static function form(Schema $schema): Schema
    {
        return AiPesanForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return AiPesanInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return AiPesansTable::configure($table);
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
            'index' => ListAiPesans::route('/'),
        ];
    }
}
