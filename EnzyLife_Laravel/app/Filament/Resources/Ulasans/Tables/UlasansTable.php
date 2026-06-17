<?php

namespace App\Filament\Resources\Ulasans\Tables;

use Filament\Actions\Action;
use Filament\Notifications\Notification;
use Illuminate\Support\Facades\Http;
use App\Models\Review;
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
                ->default('Belum Dianalisis')
                ->badge()
                ->color(fn ($state) => match ($state) {
                    'positif' => 'success',
                    'netral' => 'warning',
                    'negatif' => 'danger',
                    'Belum Dianalisis' => 'gray',
                    default => 'gray',
                }),

            TextColumn::make('sentiment_score')
                ->label('Score AI')
                ->formatStateUsing(
                    fn ($state) => $state ? number_format($state, 2) . '%' : '-'),

            TextColumn::make('komentar_aroma')
                ->label('Komentar Aroma')
                ->limit(50),

            TextColumn::make('komentar_pengiriman')
                ->label('Komentar Pengiriman')
                ->limit(50)
                ->toggleable(isToggledHiddenByDefault: true),

            TextColumn::make('created_at')
                ->label('Dibuat')
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
                Action::make('reanalyze')
                    ->label('Analisis Ulang Sentimen')
                    ->icon('heroicon-o-arrow-path')

                    ->action(function () {

                        $reviews = Review::whereNull('sentiment_label')
                            ->get();

                        $processed = 0;

                        foreach ($reviews as $review) {

                            try {

                                $response = Http::timeout(5)
                                    ->post(
                                        'http://127.0.0.1:8001/predict',
                                        [
                                            'komentar' => $review->komentar_aroma
                                        ]
                                    );

                                if ($response->successful()) {

                                    $sentiment = $response->json();

                                    $review->update([
                                        'sentiment_label' => $sentiment['label'],
                                        'sentiment_score' => $sentiment['score'],
                                    ]);

                                    $processed++;
                                }

                            } catch (\Exception $e) {
                                continue;
                            }
                        }

                        Notification::make()
                            ->title("{$processed} ulasan berhasil dianalisis")
                            ->success()
                            ->send();
                    }),

                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
