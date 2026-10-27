<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AiPercakapan extends Model
{
    protected $table = 'ai_percakapan';

    protected $primaryKey = 'id_percakapan';

    protected $fillable = [
        'id_pelanggan',
        'judul',
        'disimpan',
        'feedback',
    ];

    protected function casts(): array
    {
        return [
            'disimpan' => 'boolean',
        ];
    }

    public function pelanggan(): BelongsTo
    {
        return $this->belongsTo(User::class, 'id_pelanggan');
    }

    public function pesan(): HasMany
    {
        return $this->hasMany(
            AiPesan::class,
            'id_percakapan',
            'id_percakapan'
        )->orderBy('created_at');
    }
}
