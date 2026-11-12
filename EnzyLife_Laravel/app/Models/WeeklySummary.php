<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WeeklySummary extends Model
{
    use HasFactory;

    protected $table = 'weekly_summaries';

    protected $fillable = [
        'user_id',
        'tracker_id',
        'user_routine_id',
        'siklus_ke',
        'tanggal_mulai',
        'tanggal_selesai',
        'total_checkin',
        'target_min',
        'target_max',
        'status_pencapaian',
        'estimasi_ml_terpakai',
        'sisa_ml_stok',
        'chip_feedback',
        'catatan_refleksi',
        'is_reviewed',
    ];

    protected $casts = [
        'siklus_ke' => 'integer',
        'total_checkin' => 'integer',
        'target_min' => 'integer',
        'target_max' => 'integer',
        'estimasi_ml_terpakai' => 'float',
        'sisa_ml_stok' => 'float',
        'is_reviewed' => 'boolean',
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function userRoutine()
    {
        return $this->belongsTo(UserRoutine::class, 'user_routine_id');
    }

    public function tracker()
    {
        return $this->belongsTo(ProductTracker::class, 'tracker_id');
    }
}
