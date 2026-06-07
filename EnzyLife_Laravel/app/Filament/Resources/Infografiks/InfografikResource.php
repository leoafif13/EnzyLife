<?php

namespace App\Filament\Resources\Infografiks;

use App\Filament\Resources\Infografiks\Pages\CreateInfografik;
use App\Filament\Resources\Infografiks\Pages\EditInfografik;
use App\Filament\Resources\Infografiks\Pages\ListInfografiks;
use App\Filament\Resources\Infografiks\Schemas\InfografikForm;
use App\Filament\Resources\Infografiks\Tables\InfografiksTable;
use App\Models\Infografik;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class InfografikResource extends Resource
{
    protected static ?string $model = Infografik::class;

    protected static ?int $navigationSort = 2;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedPresentationChartBar;

    protected static ?string $label = 'Infografik';

    protected static ?string $pluralLabel = 'Infografik';

    public static function form(Schema $schema): Schema
    {
        return InfografikForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return InfografiksTable::configure($table);
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
            'index' => ListInfografiks::route('/'),
            'create' => CreateInfografik::route('/create'),
            'edit' => EditInfografik::route('/{record}/edit'),
        ];
    }
}
