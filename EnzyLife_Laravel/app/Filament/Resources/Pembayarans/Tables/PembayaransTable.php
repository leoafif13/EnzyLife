<?php

namespace App\Filament\Resources\Pembayarans\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\SelectColumn;

class PembayaransTable
{
    public static function configure(Table $table): Table
    {
        return $table
           ->columns([
            TextColumn::make('id')
                ->label('ID')
                ->sortable()
                ->searchable(),

            TextColumn::make('pemesanan.id')
                ->label('ID Pesanan'),

            TextColumn::make('pemesanan.user.name')
                ->label('Nama User'),

            TextColumn::make('total_bayar')
                ->label('Total Bayar')
                ->money('IDR'),

            TextColumn::make('pemesanan.metode_pembayaran')
                ->label('Metode'),

                SelectColumn::make('status_pembayaran')
                 ->label('Status')
                 ->options([
                     'BELUM_DIBAYAR' => 'Belum Dibayar',
                     'PENDING' => 'Pending',
                     'SUDAH_DIBAYAR' => 'Sudah Dibayar',
                     'CANCEL' => 'Dibatalkan',
                     'EXPIRE' => 'Kadaluarsa',
                     'DENY' => 'Ditolak',
                 ]),

            TextColumn::make('created_at')
                ->dateTime('d M Y H:i'),
        ])
            ->filters([
                //
            ])
            ->recordActions([
                // ViewAction::make(),
                // EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    // DeleteBulkAction::make(),
                ]),
            ]);
    }
}
