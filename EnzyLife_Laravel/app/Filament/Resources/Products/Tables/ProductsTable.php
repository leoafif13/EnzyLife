<?php

namespace App\Filament\Resources\Products\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\DeleteAction;
use Filament\Tables\Table;
use Filament\Tables;
use Filament\Tables\Columns\ImageColumn;

class ProductsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('nama')
                    ->searchable(),
                Tables\Columns\TextColumn::make('harga')
                    ->money('IDR'),
                Tables\Columns\TextColumn::make('deskripsi')
                    ->searchable(),
                Tables\Columns\TextColumn::make('spesifikasi.Volume')
                    ->label('Volume'),
                Tables\Columns\TextColumn::make('spesifikasi.Bahan')
                    ->label('Bahan Utama')
                    ->limit(30),
                Tables\Columns\TextColumn::make('spesifikasi.Lama Fermentasi')
                    ->label('Lama Fermentasi'),
                Tables\Columns\TextColumn::make('spesifikasi.Masa Simpan')
                    ->label('Masa Simpan'),
                Tables\Columns\TextColumn::make('stok')
                    ->searchable(),
                Tables\Columns\ImageColumn::make('gambar')
                    ->disk('public'),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                EditAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}