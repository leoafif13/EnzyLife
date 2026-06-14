<?php

namespace App\Filament\Resources\Ulasans;

use App\Filament\Resources\Ulasans\Pages\CreateUlasan;
use App\Filament\Resources\Ulasans\Pages\EditUlasan;
use App\Filament\Resources\Ulasans\Pages\ListUlasans;
use App\Filament\Resources\Ulasans\Pages\ViewUlasan;
use App\Filament\Resources\Ulasans\Schemas\UlasanForm;
use App\Filament\Resources\Ulasans\Schemas\UlasanInfolist;
use App\Filament\Resources\Ulasans\Tables\UlasansTable;
use App\Models\Ulasan;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;

class UlasanResource extends Resource
{
    protected static ?string $model = Review::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedRectangleStack;

    protected static ?string $navigationLabel = 'Ulasan';

    protected static ?string $pluralModelLabel = 'Ulasan';

    protected static ?string $modelLabel = 'Ulasan';

    public static function form(Schema $schema): Schema
    {
        return UlasanForm::configure($schema);
    }

    public static function infolist(Schema $schema): Schema
    {
        return UlasanInfolist::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return UlasansTable::configure($table);
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
            'index' => ListUlasans::route('/'),
            'view' => ViewUlasan::route('/{record}'),
            'edit' => EditUlasan::route('/{record}/edit'),
        ];
    }
}
