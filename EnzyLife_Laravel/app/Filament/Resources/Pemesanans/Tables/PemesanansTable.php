<?php

namespace App\Filament\Resources\Pemesanans\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\SelectColumn;

class PemesanansTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
            TextColumn::make('id')
                ->label('ID')
                ->sortable(),

            TextColumn::make('user.name')
                ->label('Pelanggan')
                ->searchable(),

            TextColumn::make('produk')
                ->label('Produk')
                ->getStateUsing(function ($record) {
                    return $record->detailPemesanan->count() . ' Produk';
                }),

            TextColumn::make('total_harga')
                ->label('Total Harga')
                ->money('IDR')
                ->sortable(),

            SelectColumn::make('status_pemesanan')
                ->label('Status')
                ->options([
                    'MENUNGGU_PEMBAYARAN' => 'Menunggu Pembayaran',
                    'DIPROSES' => 'Diproses',
                    'DIKEMAS' => 'Dikemas',
                    'DIKIRIM' => 'Dikirim',
                    'SIAP_DIAMBIL' => 'Siap Diambil',
                    'SELESAI' => 'Selesai',
                    'DIBATALKAN' => 'Dibatalkan',
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
