<?php

namespace App\Filament\Resources\AiPercakapans\Tables;

use Filament\Actions\ViewAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AiPercakapansTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('pelanggan.name')
                    ->label('Nama Pengguna')
                    ->searchable()
                    ->sortable()
                    ->placeholder('Pengguna tidak ditemukan'),

                TextColumn::make('judul')
                    ->label('Topik / Pertanyaan')
                    ->searchable()
                    ->limit(50)
                    ->placeholder('Belum ada judul'),

                TextColumn::make('pesan_count')
                    ->label('Jumlah Pesan')
                    ->counts('pesan')
                    ->sortable(),

                TextColumn::make('feedback')
                    ->label('Feedback')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        'membantu' => 'Membantu',
                        'tidak_membantu' => 'Tidak Membantu',
                        default => 'Belum Ada Feedback',
                    })
                    ->color(fn (?string $state): string => match ($state) {
                        'membantu' => 'success',
                        'tidak_membantu' => 'danger',
                        default => 'gray',
                    }),

                IconColumn::make('disimpan')
                    ->label('Tersimpan')
                    ->boolean(),

                TextColumn::make('created_at')
                    ->label('Waktu Konsultasi')
                    ->dateTime('d M Y, H:i')
                    ->sortable(),

                TextColumn::make('updated_at')
                    ->label('Terakhir Diperbarui')
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
