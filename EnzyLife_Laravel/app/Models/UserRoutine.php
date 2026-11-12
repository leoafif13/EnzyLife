<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class UserRoutine extends Model
{
    use HasFactory;

    protected $table = 'user_routines';

    protected $fillable = [
        'user_id',
        'tracker_id',
        'pemesanan_id',
        'produk_id',
        'kategori_nama',
        'tipe_target',
        'target_min',
        'target_max',
        'takaran_ml_per_pakai',
        'jam_pengingat',
        'tanggal_mulai_siklus',
        'siklus_ke',
        'status_rutinitas',
        'stok_awal_ml',
        'stok_sisa_ml',
    ];

    protected $casts = [
        'target_min' => 'integer',
        'target_max' => 'integer',
        'siklus_ke' => 'integer',
        'takaran_ml_per_pakai' => 'float',
        'stok_awal_ml' => 'integer',
        'stok_sisa_ml' => 'float',
        'tanggal_mulai_siklus' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function tracker()
    {
        return $this->belongsTo(ProductTracker::class, 'tracker_id');
    }

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }

    public function produk()
    {
        return $this->belongsTo(Product::class, 'produk_id');
    }

    public function checkins()
    {
        return $this->hasMany(RoutineCheckin::class, 'user_routine_id');
    }

    public function weeklySummaries()
    {
        return $this->hasMany(WeeklySummary::class, 'user_routine_id');
    }

    /**
     * Hitung hari ke- (1 sampai 7) dari siklus aktif.
     */
    public function getHariKeAttribute(): int
    {
        $mulai = Carbon::parse($this->tanggal_mulai_siklus)->startOfDay();
        $hari = (int) $mulai->diffInDays(Carbon::today()->startOfDay()) + 1;
        return max(1, min(7, $hari));
    }

    /**
     * Cek apakah hari ini sudah jatuh tempo hari ke-7 (waktunya rekap mingguan).
     */
    public function getIsHariKeTujuhAttribute(): bool
    {
        $mulai = Carbon::parse($this->tanggal_mulai_siklus)->startOfDay();
        $diff = (int) $mulai->diffInDays(Carbon::today()->startOfDay());
        return $diff >= 6; // Hari ke-7 (index 0-6 atau lebih)
    }

    /**
     * Checkin untuk siklus saat ini.
     */
    public function currentCycleCheckins()
    {
        return $this->hasMany(RoutineCheckin::class, 'user_routine_id')
            ->where('siklus_ke', $this->siklus_ke);
    }
}
