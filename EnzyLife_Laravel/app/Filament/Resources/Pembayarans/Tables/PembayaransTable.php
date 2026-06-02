<?php

namespace App\Filament\Resources\Pembayarans\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class PembayaransTable
{
    public static function configure(Table $table): Table
    {
        return $table
           ->columns([
            TextColumn::make('id')
                ->label('ID')
                ->sortable(),

            TextColumn::make('pemesanan.id')
                ->label('ID Pesanan'),

            TextColumn::make('pemesanan.user.name')
                ->label('Nama User'),

            TextColumn::make('total_bayar')
                ->label('Total Bayar')
                ->money('IDR'),

            TextColumn::make('payment_type')
                ->label('Metode'),

            TextColumn::make('status_pembayaran')
                ->badge()
                ->color(fn (string $state): string => match ($state) {
                    'BELUM_DIBAYAR' => 'warning',
                    'PENDING' => 'info',
                    'SETTLEMENT' => 'success',
                    'SUDAH_DIBAYAR' => 'success',
                    'EXPIRE' => 'danger',
                    'CANCEL' => 'danger',
                    'DENY' => 'danger',
                    default => 'gray',
                }),

            TextColumn::make('created_at')
                ->dateTime('d M Y H:i'),
        ])
            ->filters([
                //
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
