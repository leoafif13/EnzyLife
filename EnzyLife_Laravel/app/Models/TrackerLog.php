<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class TrackerLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'tracker_id',
        'tanggal',
        'waktu',
        'catatan',
    ];

    protected $casts = [
        'tanggal' => 'date',
    ];

    public function tracker()
    {
        return $this->belongsTo(ProductTracker::class, 'tracker_id');
    }
}
