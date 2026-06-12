<?php

namespace App\Filament\Resources\Ulasans\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Tables\Filters\SelectFilter;

class UlasansTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
            TextColumn::make('user.name')
                ->label('User')
                ->searchable(),

            TextColumn::make('produk.nama')
                ->label('Produk')
                ->searchable(),

            TextColumn::make('rating')
                ->label('Rating')
                ->formatStateUsing(fn ($state) => str_repeat('⭐', (int) $state)),

            TextColumn::make('sentiment_label')
                ->label('Sentimen')
                ->badge()
                ->color(fn (?string $state): string => match ($state) {
                    'positif' => 'success',
                    'netral' => 'warning',
                    'negatif' => 'danger',
                    default => 'gray',
                }),

            TextColumn::make('sentiment_score')
                ->label('Score AI')
                ->numeric(decimalPlaces: 2)
                ->suffix('%')
                ->sortable(),

            TextColumn::make('komentar_aroma')
                ->label('Komentar Aroma')
                ->limit(50),

            TextColumn::make('komentar_pengiriman')
                ->label('Komentar Pengiriman')
                ->limit(50)
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('created_at')
                ->label('Tanggal')
                ->dateTime('d M Y H:i')
                ->sortable(),
            ])
            ->filters([
                SelectFilter::make('sentiment_label')
                ->options([
                    'positif' => 'Positif',
                    'netral' => 'Netral',
                    'negatif' => 'Negatif',
                ]),
            ])
            ->recordActions([
                ViewAction::make(),
                // EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
