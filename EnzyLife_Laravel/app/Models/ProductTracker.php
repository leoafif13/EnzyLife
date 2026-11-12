<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ProductTracker extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'pemesanan_id',
        'produk_id',
        'tanggal_mulai',
        'tanggal_selesai',
        'tanggal_perpanjangan',
        'catatan_hasil',
        'status',
    ];

    protected $casts = [
        'tanggal_mulai' => 'date',
        'tanggal_selesai' => 'date',
        'tanggal_perpanjangan' => 'date',
    ];

    /**
     * Tanggal batas akhir tracking (perpanjangan kalau ada, kalau nggak ya selesai).
     */
    public function getBatasAkhirAttribute()
    {
        return $this->tanggal_perpanjangan ?? $this->tanggal_selesai;
    }

    /**
     * Hitung hari ke berapa sejak mulai tracking.
     */
    public function getHariKeAttribute(): int
    {
        if (!$this->tanggal_mulai) {
            return 1;
        }
        return (int) $this->tanggal_mulai->copy()->startOfDay()->diffInDays(now()->startOfDay()) + 1;
    }

    /**
     * Cek apakah tracker masih dalam periode aktif.
     */
    public function isMasihAktif(): bool
    {
        if (!in_array($this->status, ['AKTIF', 'PERPANJANGAN'])) {
            return false;
        }

        if (!$this->batas_akhir) {
            return false;
        }

        return now()->lte($this->batas_akhir->copy()->endOfDay());
    }

    /**
     * Cek apakah sudah memasuki minggu ke-3 (hari ke-15+).
     */
    public function isSudahMingguKeTiga(): bool
    {
        return $this->hari_ke >= 15;
    }

    // ─── Relationships ───

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function pemesanan()
    {
        return $this->belongsTo(Pemesanan::class);
    }

    public function produk()
    {
        return $this->belongsTo(Product::class, 'produk_id');
    }

    public function logs()
    {
        return $this->hasMany(TrackerLog::class, 'tracker_id');
    }

    public function review()
    {
        return $this->hasOne(Review::class, 'tracker_id');
    }

    public function routines()
    {
        return $this->hasMany(UserRoutine::class, 'tracker_id');
    }

    public function weeklySummaries()
    {
        return $this->hasMany(WeeklySummary::class, 'tracker_id');
    }
}
