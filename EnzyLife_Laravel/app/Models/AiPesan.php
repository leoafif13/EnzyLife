<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiPesan extends Model
{
    protected $table = 'ai_pesan';

    protected $primaryKey = 'id_pesan';

    protected $fillable = [
        'id_percakapan',
        'peran',
        'isi',
    ];

    public function percakapan(): BelongsTo
    {
        return $this->belongsTo(
            AiPercakapan::class,
            'id_percakapan',
            'id_percakapan'
        );
    }
}
