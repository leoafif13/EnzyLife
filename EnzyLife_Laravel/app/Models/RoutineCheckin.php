<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RoutineCheckin extends Model
{
    use HasFactory;

    protected $table = 'routine_checkins';

    protected $fillable = [
        'user_routine_id',
        'siklus_ke',
        'hari_ke',
        'tanggal',
        'waktu',
    ];

    protected $casts = [
        'siklus_ke' => 'integer',
        'hari_ke' => 'integer',
        'tanggal' => 'date',
    ];

    public function userRoutine()
    {
        return $this->belongsTo(UserRoutine::class, 'user_routine_id');
    }
}
