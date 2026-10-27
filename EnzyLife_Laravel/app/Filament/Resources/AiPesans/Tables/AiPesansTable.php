<?php

namespace App\Filament\Resources\AiPesans\Tables;

use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AiPesansTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('percakapan.pelanggan.name')
                    ->label('Nama Pengguna')
                    ->searchable()
                    ->sortable()
                    ->placeholder('Pengguna tidak ditemukan'),

                TextColumn::make('id_percakapan')
                    ->label('ID Percakapan')
                    ->sortable(),

                TextColumn::make('peran')
                    ->label('Pengirim')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'user' => 'Pengguna',
                        'assistant' => 'AI EnzyLife',
                        default => $state ?? '-',
                    }),

                TextColumn::make('isi')
                    ->label('Isi Pesan')
                    ->searchable()
                    ->formatStateUsing(fn (?string $state): string =>
                        preg_replace('/\*\*(.*?)\*\*/s', '$1', $state ?? '')
                    )
                    ->limit(100)
                    ->wrap(),

                TextColumn::make('created_at')
                    ->label('Waktu Pesan')
                    ->dateTime('d M Y, H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->recordActions([
                // ViewAction::make()
                //     ->label('Detail'),
            ]);
    }
}
