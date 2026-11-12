<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserRoutine;
use App\Models\RoutineCheckin;
use App\Models\WeeklySummary;
use App\Models\ProductTracker;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RoutineTrackerController extends Controller
{
    // Konfigurasi template takaran & target default (berdasarkan kalkulator rasio di aplikasi)
    protected static $kategoriDefaults = [
        'Kompor & Area Dapur' => [
            'tipe' => 'HARIAN',
            'min' => 5,
            'max' => 7,
            'ml' => 45.0,
            'air' => '450 mL Air',
            'wadah' => 'Botol Semprot 500 mL',
            'rasio' => '1 : 10 Air',
            'takaran_lengkap' => '45 mL Eco Enzyme + 450 mL Air',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 0,
        ],
        'Pel Lantai' => [
            'tipe' => 'MINGGUAN',
            'min' => 2,
            'max' => 3,
            'ml' => 50.0,
            'air' => '2.5 Liter Air',
            'wadah' => 'Ember Pel',
            'rasio' => '1 : 50 Air',
            'takaran_lengkap' => '50 mL Eco Enzyme + 2.5 Liter Air',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 2,
        ],
        'Cuci Piring' => [
            'tipe' => 'HARIAN',
            'min' => 5,
            'max' => 7,
            'ml' => 100.0,
            'air' => '100 mL Sabun Cuci Piring',
            'wadah' => 'Botol Sabun 200 mL',
            'rasio' => '1 : 1 Sabun Cuci Piring',
            'takaran_lengkap' => '100 mL Eco Enzyme + 100 mL Sabun Cuci Piring',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 0,
        ],
        'Cuci Pakaian' => [
            'tipe' => 'MINGGUAN',
            'min' => 2,
            'max' => 4,
            'ml' => 50.0,
            'air' => '500 mL Air (atau campur deterjen)',
            'wadah' => 'Mesin Cuci',
            'rasio' => '1 : 10 Deterjen / Air',
            'takaran_lengkap' => '50 mL Eco Enzyme + 500 mL Air / Deterjen',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 2,
        ],
        'Kamar Mandi' => [
            'tipe' => 'MINGGUAN',
            'min' => 1,
            'max' => 2,
            'ml' => 50.0,
            'air' => '500 mL Air',
            'wadah' => 'Botol Semprot / Gayung',
            'rasio' => '1 : 10 Air',
            'takaran_lengkap' => '50 mL Eco Enzyme + 500 mL Air',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 3,
        ],
        'Saluran Air' => [
            'tipe' => 'FLEKSIBEL',
            'min' => 1,
            'max' => 2,
            'ml' => 250.0,
            'air' => '250 mL Air Hangat',
            'wadah' => 'Gayung 1 Liter',
            'rasio' => '1 : 1 Air',
            'takaran_lengkap' => '250 mL Eco Enzyme + 250 mL Air Hangat',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 3,
        ],
        'Penghilang Bau' => [
            'tipe' => 'FLEKSIBEL',
            'min' => 1,
            'max' => 5,
            'ml' => 1.0,
            'air' => '500 mL Air',
            'wadah' => 'Botol Semprot 500 mL',
            'rasio' => '1 : 500 Air',
            'takaran_lengkap' => '1 mL Eco Enzyme (±20 tetes) + 500 mL Air',
            'kelompok' => 'Rumah Tangga',
            'jeda_hari' => 1,
        ],
        'Pupuk Organik' => [
            'tipe' => 'MINGGUAN',
            'min' => 1,
            'max' => 2,
            'ml' => 1.0,
            'air' => '1 Liter Air',
            'wadah' => 'Semprotan 1 Liter',
            'rasio' => '1 : 1000 Air',
            'takaran_lengkap' => '1 mL Eco Enzyme (±20 tetes) + 1 Liter Air',
            'kelompok' => 'Pertanian',
            'jeda_hari' => 3,
        ],
        'Pestisida Sayuran' => [
            'tipe' => 'MINGGUAN',
            'min' => 1,
            'max' => 2,
            'ml' => 2.0,
            'air' => '1 Liter Air',
            'wadah' => 'Semprotan 1 Liter',
            'rasio' => '1 : 500 Air',
            'takaran_lengkap' => '2 mL Eco Enzyme + 1 Liter Air',
            'kelompok' => 'Pertanian',
            'jeda_hari' => 3,
        ],
        'Kompos' => [
            'tipe' => 'MINGGUAN',
            'min' => 1,
            'max' => 1,
            'ml' => 10.0,
            'air' => '1 Liter Air',
            'wadah' => 'Siram 1 Liter',
            'rasio' => '1 : 100 Air',
            'takaran_lengkap' => '10 mL Eco Enzyme + 1 Liter Air',
            'kelompok' => 'Pertanian',
            'jeda_hari' => 7,
        ],
        'Air Purifier' => [
            'tipe' => 'FLEKSIBEL',
            'min' => 1,
            'max' => 3,
            'ml' => 0.5,
            'air' => '500 mL Air',
            'wadah' => 'Diffuser 500 mL',
            'rasio' => '1 : 1000 Air',
            'takaran_lengkap' => '0.5 mL Eco Enzyme (±10 tetes) + 500 mL Air',
            'kelompok' => 'Lingkungan',
            'jeda_hari' => 2,
        ],
    ];

    /**
     * Dapatkan daftar template kategori yang tersedia untuk dipilih saat setup.
     */
    public function getCategories()
    {
        $list = [];
        foreach (self::$kategoriDefaults as $nama => $cfg) {
            $list[] = [
                'nama' => $nama,
                'tipe_target' => $cfg['tipe'],
                'target_min' => $cfg['min'],
                'target_max' => $cfg['max'],
                'takaran_ml' => $cfg['ml'],
                'rasio_label' => $cfg['rasio'],
                'kelompok' => $cfg['kelompok'],
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $list,
        ]);
    }

    /**
     * Setup awal: User memilih kategori-kategori rutinitas penggunaan untuk produk yang dibeli.
     */
    public function setup(Request $request)
    {
        // Fallback jika dikirim raw JSON dengan content-type x-www-form-urlencoded
        if (!$request->has('kategori') && !empty($request->getContent())) {
            $jsonData = json_decode($request->getContent(), true);
            if (is_array($jsonData)) {
                $request->merge($jsonData);
            }
        }

        // Normalisasi kategori jika dikirim sebagai string json
        if (is_string($request->kategori)) {
            $decoded = json_decode($request->kategori, true);
            if (is_array($decoded)) {
                $request->merge(['kategori' => $decoded]);
            } else {
                $request->merge(['kategori' => array_map('trim', explode(',', $request->kategori))]);
            }
        }

        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'kategori' => 'required|array|min:1',
            'kategori.*' => 'required|string',
            'tracker_id' => 'nullable',
            'jam_pengingat' => 'nullable|string',
            'stok_awal_ml' => 'nullable|numeric',
            'pemesanan_id' => 'nullable',
            'produk_id' => 'nullable',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => $validator->errors()->first(),
                'errors' => $validator->errors(),
            ], 422);
        }

        $userId = $request->user()?->id ?? auth()->id();
        $jamPengingat = $request->jam_pengingat ?? '19:00';
        $stokAwal = (float) ($request->stok_awal_ml ?? 1000);
        $today = Carbon::today();

        $trackerId = $request->tracker_id ? (int) $request->tracker_id : null;
        $pemesananId = $request->pemesanan_id ? (int) $request->pemesanan_id : null;
        $produkId = $request->produk_id ? (int) $request->produk_id : null;

        if ($trackerId) {
            $tracker = null;
            if ($userId) {
                $tracker = ProductTracker::where('user_id', $userId)->find($trackerId);
            }
            if (!$tracker) {
                $tracker = ProductTracker::find($trackerId);
            }
            if ($tracker) {
                if (!$userId) {
                    $userId = $tracker->user_id;
                }
                $pemesananId = $tracker->pemesanan_id;
                $produkId = $tracker->produk_id;
            }
        }

        DB::beginTransaction();
        try {
            $created = [];
            $existingNames = [];
            $activeSiklus = 1;
            $activeMulaiSiklus = $today;

            if ($trackerId) {
                // Ambil rutinitas yang sudah ada untuk tracker ini (JANGAN DIHAPUS)
                $existingRoutines = UserRoutine::where('tracker_id', $trackerId)->get();
                $existingNames = $existingRoutines->pluck('kategori_nama')->toArray();
                if ($existingRoutines->isNotEmpty()) {
                    $activeSiklus = $existingRoutines->first()->siklus_ke;
                    $activeMulaiSiklus = $existingRoutines->first()->tanggal_mulai_siklus;
                }
            } else {
                // Fallback rutinitas standalone tanpa tracker
                $standalone = UserRoutine::where('user_id', $userId)
                    ->whereNull('tracker_id')
                    ->where('status_rutinitas', 'AKTIF')
                    ->get();
                $existingNames = $standalone->pluck('kategori_nama')->toArray();
                if ($standalone->isNotEmpty()) {
                    $activeSiklus = $standalone->first()->siklus_ke;
                    $activeMulaiSiklus = $standalone->first()->tanggal_mulai_siklus;
                }
            }

            foreach ($request->kategori as $kategoriNama) {
                // Jika kategori sudah ada, pertahankan (jangan buat ulang atau hapus)
                if (in_array($kategoriNama, $existingNames)) {
                    continue;
                }

                $cfg = self::$kategoriDefaults[$kategoriNama] ?? [
                    'tipe' => 'MINGGUAN',
                    'min' => 2,
                    'max' => 3,
                    'ml' => 50.0,
                ];

                $routine = UserRoutine::create([
                    'user_id' => $userId,
                    'tracker_id' => $trackerId,
                    'pemesanan_id' => $pemesananId,
                    'produk_id' => $produkId,
                    'kategori_nama' => $kategoriNama,
                    'tipe_target' => $cfg['tipe'],
                    'target_min' => $cfg['min'],
                    'target_max' => $cfg['max'],
                    'takaran_ml_per_pakai' => $cfg['ml'],
                    'jam_pengingat' => $jamPengingat,
                    'tanggal_mulai_siklus' => $today,
                    'siklus_ke' => 1,
                    'status_rutinitas' => 'AKTIF',
                    'stok_awal_ml' => $stokAwal,
                    'stok_sisa_ml' => $stokAwal,
                ]);

                $created[] = $routine;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Kategori rutinitas berhasil disiapkan! Siklus Minggu 1 dimulai.',
                'data' => $created,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyiapkan rutinitas: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Dashboard Rutinitas Hari Ini untuk Tracker Produk:
     * Menampilkan progres "6 dari 5-7x", status hari ini, dan status rekap mingguan.
     */
    public function dashboard(Request $request)
    {
        $userId = auth()->id();
        $trackerId = $request->query('tracker_id');

        $query = UserRoutine::with(['produk', 'tracker.produk', 'tracker.pemesanan'])
            ->where('user_id', $userId)
            ->where('status_rutinitas', 'AKTIF');

        if ($trackerId) {
            $query->where('tracker_id', $trackerId);
        }

        $routines = $query->get();

        // Cari tracker terkait
        $tracker = null;
        if ($trackerId) {
            $tracker = ProductTracker::where('user_id', $userId)
                ->with(['produk', 'pemesanan'])
                ->find($trackerId);
        }

        if ($routines->isEmpty()) {
            return response()->json([
                'success' => true,
                'has_routines' => false,
                'tracker' => $tracker,
                'data' => [],
            ]);
        }

        $today = Carbon::today()->toDateString();
        $firstRoutine = $routines->first();
        $siklusKe = $firstRoutine->siklus_ke; // Minggu 1, 2, 3, atau 4
        $mulaiSiklus = Carbon::parse($firstRoutine->tanggal_mulai_siklus)->startOfDay();
        $hariKe = (int) $mulaiSiklus->diffInDays(Carbon::today()->startOfDay()) + 1;
        $hariKe = max(1, min(7, $hariKe));
        $isHariKeTujuh = $mulaiSiklus->diffInDays(Carbon::today()->startOfDay()) >= 6;

        // Bangun strip kalender 7 hari untuk siklus saat ini
        $dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
        $calendarDays = [];
        for ($i = 0; $i < 7; $i++) {
            $dayDate = $mulaiSiklus->copy()->addDays($i);
            $dayDateStr = $dayDate->toDateString();
            $dow = $dayDate->dayOfWeekIso - 1; // 0 = Sen, 6 = Min
            $calendarDays[] = [
                'index' => $i + 1,
                'date' => $dayDateStr,
                'day_name' => $dayNames[$dow] ?? $dayDate->format('D'),
                'day_num' => $dayDate->format('d M'),
                'is_today' => $dayDateStr === $today,
                'is_past' => $dayDate->startOfDay()->lt(Carbon::today()->startOfDay()),
                'is_future' => $dayDate->startOfDay()->gt(Carbon::today()->startOfDay()),
            ];
        }

        $items = [];
        $totalTerpakaiMl = 0.0;
        $stokSisaTerendah = null;

        foreach ($routines as $routine) {
            // Checkin pada siklus ini
            $cycleCheckins = RoutineCheckin::where('user_routine_id', $routine->id)
                ->where('siklus_ke', $routine->siklus_ke)
                ->get();

            $totalCheckinCycle = $cycleCheckins->count();
            $checkedDates = $cycleCheckins->pluck('tanggal')->map(fn($d) => Carbon::parse($d)->toDateString())->toArray();
            $hasCheckedToday = in_array($today, $checkedDates);

            // Jarak hari dari checkin terakhir
            $lastCheckin = $cycleCheckins->sortByDesc('tanggal')->first();
            $daysSinceLast = null;
            if ($lastCheckin) {
                $daysSinceLast = Carbon::parse($lastCheckin->tanggal)->diffInDays(Carbon::today());
            }

            // Hitung status pemakaian
            $statusLabel = 'Dalam Progres';
            if ($routine->tipe_target === 'FLEKSIBEL') {
                $statusLabel = 'Fleksibel';
            } elseif ($totalCheckinCycle >= $routine->target_max) {
                $statusLabel = 'Optimal';
            } elseif ($totalCheckinCycle >= $routine->target_min) {
                $statusLabel = 'Tercapai';
            } else {
                $statusLabel = 'Belum Tercapai';
            }

            $cfg = self::$kategoriDefaults[$routine->kategori_nama] ?? [];
            $terpakaiMl = $totalCheckinCycle * $routine->takaran_ml_per_pakai;
            $totalTerpakaiMl += $terpakaiMl;

            if ($stokSisaTerendah === null || $routine->stok_sisa_ml < $stokSisaTerendah) {
                $stokSisaTerendah = $routine->stok_sisa_ml;
            }

            // Jadwal jeda rekomendasi (hanya pemakaian 2-3x seminggu agar tidak setiap hari)
            $jadwalRekomendasi = null;
            if ($routine->tipe_target === 'MINGGUAN') {
                $jeda = $cfg['jeda_hari'] ?? 2;
                if ($hasCheckedToday) {
                    $nextDay = Carbon::today()->addDays($jeda);
                    $jadwalRekomendasi = 'Selesai hari ini! Jadwal berikutnya: ' . $nextDay->format('d M') . ' (Jeda ' . $jeda . ' hari agar pas 2x seminggu)';
                } else {
                    $jadwalRekomendasi = 'Rekomendasi: gunakan dengan jeda 2-3 hari (Target ' . $routine->target_min . '-' . $routine->target_max . 'x seminggu)';
                }
            } elseif ($routine->tipe_target === 'HARIAN') {
                $jadwalRekomendasi = 'Rutin setiap hari (Target 5-7x seminggu)';
            } else {
                $jadwalRekomendasi = 'Pakai sesuai kebutuhan Anda';
            }

            $routineMulai = Carbon::parse($routine->tanggal_mulai_siklus)->startOfDay();
            $routineHariKe = (int) $routineMulai->diffInDays(Carbon::today()->startOfDay()) + 1;
            $routineHariKe = max(1, min(7, $routineHariKe));
            $isRoutineRecapReady = $routineMulai->diffInDays(Carbon::today()->startOfDay()) >= 6;

            $items[] = [
                'id' => $routine->id,
                'tracker_id' => $routine->tracker_id,
                'kategori_nama' => $routine->kategori_nama,
                'siklus_ke' => $routine->siklus_ke,
                'hari_ke' => $routineHariKe,
                'tanggal_mulai' => $routine->tanggal_mulai_siklus,
                'is_recap_ready' => $isRoutineRecapReady,
                'tipe_target' => $routine->tipe_target,
                'target_min' => $routine->target_min,
                'target_max' => $routine->target_max,
                'total_checkin' => $totalCheckinCycle,
                'has_checked_today' => $hasCheckedToday,
                'days_since_last' => $daysSinceLast,
                'status_label' => $statusLabel,
                'takaran_ml_per_pakai' => $routine->takaran_ml_per_pakai,
                'takaran_lengkap' => $cfg['takaran_lengkap'] ?? ($routine->takaran_ml_per_pakai . ' mL Eco Enzyme + Air'),
                'air_label' => $cfg['air'] ?? null,
                'wadah_label' => $cfg['wadah'] ?? null,
                'rasio_label' => $cfg['rasio'] ?? null,
                'jadwal_rekomendasi' => $jadwalRekomendasi,
                'checked_dates' => $checkedDates,
                'stok_sisa_ml' => $routine->stok_sisa_ml,
                'produk' => $routine->produk ?? ($tracker ? $tracker->produk : null),
            ];
        }

        // Estimasi sisa minggu dari pemakaian rata-rata
        $avgWeeklyConsumption = max(1.0, $totalTerpakaiMl);
        $sisaMinggu = $stokSisaTerendah !== null ? round($stokSisaTerendah / $avgWeeklyConsumption, 1) : null;

        // Mandiri & berhak ulasan terverifikasi jika sudah minggu ke-3 atau ke-4
        $isMandiri = $siklusKe >= 3;

        return response()->json([
            'success' => true,
            'has_routines' => true,
            'tracker' => $tracker,
            'siklus_ke' => $siklusKe, // Minggu 1, 2, 3, 4
            'max_siklus' => 4,
            'hari_ke' => $hariKe, // Hari 1-7 dalam minggu berjalan
            'calendar_days' => $calendarDays,
            'is_recap_ready' => $isHariKeTujuh,
            'total_terpakai_siklus_ml' => round($totalTerpakaiMl, 1),
            'stok_sisa_ml' => $stokSisaTerendah !== null ? round($stokSisaTerendah, 1) : 1000.0,
            'prediksi_sisa_minggu' => $sisaMinggu,
            'can_unlock_verified_review' => $isMandiri,
            'is_mandiri' => $isMandiri,
            'routines' => $items,
        ]);
    }

    /**
     * 1-Tap Check-in: User menekan "Sudah Dipakai" hari ini.
     */
    public function checkin(Request $request, $routineId)
    {
        $userId = auth()->id();
        $routine = UserRoutine::where('user_id', $userId)
            ->where('id', $routineId)
            ->firstOrFail();

        $today = Carbon::today()->toDateString();
        $now = Carbon::now()->format('H:i:s');

        // Cek apakah sudah checkin hari ini
        $already = RoutineCheckin::where('user_routine_id', $routine->id)
            ->where('tanggal', $today)
            ->exists();

        if ($already) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah mencatat pemakaian untuk kategori ini hari ini.',
            ], 400);
        }

        $mulaiSiklus = Carbon::parse($routine->tanggal_mulai_siklus)->startOfDay();
        $hariKe = (int) $mulaiSiklus->diffInDays(Carbon::today()->startOfDay()) + 1;
        $hariKe = max(1, min(7, $hariKe));

        DB::beginTransaction();
        try {
            $checkin = RoutineCheckin::create([
                'user_routine_id' => $routine->id,
                'siklus_ke' => $routine->siklus_ke,
                'hari_ke' => $hariKe,
                'tanggal' => $today,
                'waktu' => $now,
            ]);

            // Potong stok sisa
            $sisaBaru = max(0.0, $routine->stok_sisa_ml - $routine->takaran_ml_per_pakai);
            $routine->update(['stok_sisa_ml' => $sisaBaru]);

            DB::commit();

            // Hitung total pemakaian di siklus ini
            $totalCheckin = RoutineCheckin::where('user_routine_id', $routine->id)
                ->where('siklus_ke', $routine->siklus_ke)
                ->count();

            return response()->json([
                'success' => true,
                'message' => 'Catatan pemakaian berhasil disimpan! ✨',
                'data' => [
                    'checkin' => $checkin,
                    'total_checkin' => $totalCheckin,
                    'stok_sisa_ml' => $sisaBaru,
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal mencatat check-in: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Batalkan checkin hari ini (jika user salah pencet).
     */
    public function uncheckin(Request $request, $routineId)
    {
        $userId = auth()->id();
        $routine = UserRoutine::where('user_id', $userId)
            ->where('id', $routineId)
            ->firstOrFail();

        $today = Carbon::today()->toDateString();

        $checkin = RoutineCheckin::where('user_routine_id', $routine->id)
            ->where('tanggal', $today)
            ->first();

        if (!$checkin) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada check-in hari ini untuk dibatalkan.',
            ], 400);
        }

        DB::beginTransaction();
        try {
            $checkin->delete();

            // Kembalikan sisa stok
            $sisaBaru = min($routine->stok_awal_ml, $routine->stok_sisa_ml + $routine->takaran_ml_per_pakai);
            $routine->update(['stok_sisa_ml' => $sisaBaru]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Catatan pemakaian hari ini telah dibatalkan.',
                'data' => [
                    'stok_sisa_ml' => $sisaBaru,
                ],
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal membatalkan check-in: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Rekap Hari ke-7: Mengambil kalkulasi rekap mingguan untuk semua kategori pada tracker ini.
     */
    public function weeklyRecap(Request $request)
    {
        $userId = auth()->id();
        $trackerId = $request->query('tracker_id');

        $query = UserRoutine::where('user_id', $userId)
            ->where('status_rutinitas', 'AKTIF');

        if ($trackerId) {
            $query->where('tracker_id', $trackerId);
        }

        $routines = $query->get();

        if ($routines->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada rutinitas aktif.',
            ], 404);
        }

        $firstRoutine = $routines->first();
        $siklusKe = $firstRoutine->siklus_ke;
        $tglMulai = $firstRoutine->tanggal_mulai_siklus;
        $tglSelesai = Carbon::parse($tglMulai)->addDays(6)->toDateString();

        $recapItems = [];
        $totalTerpakaiMl = 0.0;
        $stokSisaTerendah = null;

        foreach ($routines as $routine) {
            $checkins = RoutineCheckin::where('user_routine_id', $routine->id)
                ->where('siklus_ke', $siklusKe)
                ->get();

            $total = $checkins->count();
            $terpakai = $total * $routine->takaran_ml_per_pakai;
            $totalTerpakaiMl += $terpakai;

            $status = 'BELUM_TERCAPAI';
            if ($routine->tipe_target === 'FLEKSIBEL') {
                $status = 'FLEKSIBEL';
            } elseif ($total >= $routine->target_max) {
                $status = 'OPTIMAL';
            } elseif ($total >= $routine->target_min) {
                $status = 'TERCAPAI';
            }

            if ($stokSisaTerendah === null || $routine->stok_sisa_ml < $stokSisaTerendah) {
                $stokSisaTerendah = $routine->stok_sisa_ml;
            }

            $recapItems[] = [
                'routine_id' => $routine->id,
                'kategori_nama' => $routine->kategori_nama,
                'tipe_target' => $routine->tipe_target,
                'total_checkin' => $total,
                'target_min' => $routine->target_min,
                'target_max' => $routine->target_max,
                'status_pencapaian' => $status,
                'estimasi_ml_terpakai' => round($terpakai, 1),
            ];
        }

        $avgWeekly = max(1.0, $totalTerpakaiMl);
        $sisaMinggu = $stokSisaTerendah !== null ? round($stokSisaTerendah / $avgWeekly, 1) : null;

        return response()->json([
            'success' => true,
            'siklus_ke' => $siklusKe,
            'max_siklus' => 4,
            'tanggal_mulai' => $tglMulai,
            'tanggal_selesai' => $tglSelesai,
            'total_ml_terpakai' => round($totalTerpakaiMl, 1),
            'stok_sisa_ml' => $stokSisaTerendah !== null ? round($stokSisaTerendah, 1) : 1000.0,
            'prediksi_sisa_minggu' => $sisaMinggu,
            'can_unlock_verified_review' => $siklusKe >= 3,
            'is_selesai' => $siklusKe >= 4,
            'items' => $recapItems,
        ]);
    }

    /**
     * Submit Rekap Hari ke-7 & Mulai Siklus Baru Otomatis (hingga 3-4 minggu).
     */
    public function submitRecap(Request $request)
    {
        $request->validate([
            'tracker_id' => 'nullable|exists:product_trackers,id',
            'chip_feedback' => 'nullable|string',
            'catatan_refleksi' => 'nullable|string|max:1000',
            'tandai_selesai' => 'nullable|boolean',
        ]);

        $userId = auth()->id();
        $trackerId = $request->tracker_id;

        $query = UserRoutine::where('user_id', $userId)
            ->where('status_rutinitas', 'AKTIF');

        if ($trackerId) {
            $query->where('tracker_id', $trackerId);
        }

        $routines = $query->get();

        if ($routines->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Tidak ada rutinitas aktif.',
            ], 404);
        }

        DB::beginTransaction();
        try {
            $firstRoutine = $routines->first();
            $siklusLama = $firstRoutine->siklus_ke;
            $tglMulai = $firstRoutine->tanggal_mulai_siklus;
            $tglSelesai = Carbon::parse($tglMulai)->addDays(6)->toDateString();

            foreach ($routines as $routine) {
                $totalCheckin = RoutineCheckin::where('user_routine_id', $routine->id)
                    ->where('siklus_ke', $siklusLama)
                    ->count();

                $terpakai = $totalCheckin * $routine->takaran_ml_per_pakai;

                $status = 'BELUM_TERCAPAI';
                if ($routine->tipe_target === 'FLEKSIBEL') {
                    $status = 'FLEKSIBEL';
                } elseif ($totalCheckin >= $routine->target_max) {
                    $status = 'OPTIMAL';
                } elseif ($totalCheckin >= $routine->target_min) {
                    $status = 'TERCAPAI';
                }

                // Catat ke weekly_summaries
                WeeklySummary::create([
                    'user_id' => $userId,
                    'tracker_id' => $routine->tracker_id,
                    'user_routine_id' => $routine->id,
                    'siklus_ke' => $siklusLama,
                    'tanggal_mulai' => $tglMulai,
                    'tanggal_selesai' => $tglSelesai,
                    'total_checkin' => $totalCheckin,
                    'target_min' => $routine->target_min,
                    'target_max' => $routine->target_max,
                    'status_pencapaian' => $status,
                    'estimasi_ml_terpakai' => $terpakai,
                    'sisa_ml_stok' => $routine->stok_sisa_ml,
                    'chip_feedback' => $request->chip_feedback,
                    'catatan_refleksi' => $request->catatan_refleksi,
                ]);

                // Cek apakah selesai (minggu ke-4 atau user pilih selesai di minggu ke-3)
                $isCompleted = ($siklusLama >= 4) || ($siklusLama >= 3 && $request->tandai_selesai == true);

                if ($isCompleted) {
                    $routine->update([
                        'status_rutinitas' => 'SELESAI',
                    ]);
                } else {
                    $routine->update([
                        'siklus_ke' => $siklusLama + 1,
                        'tanggal_mulai_siklus' => Carbon::today(),
                    ]);
                }
            }

            // Jika tracker_id ada dan sudah selesai, tandai ProductTracker sebagai SELESAI
            if ($trackerId && (($siklusLama >= 4) || ($siklusLama >= 3 && $request->tandai_selesai == true))) {
                ProductTracker::where('id', $trackerId)->update([
                    'status' => 'SELESAI',
                    'catatan_hasil' => $request->catatan_refleksi ?? $request->chip_feedback,
                ]);
            }

            DB::commit();

            $isCompleted = ($siklusLama >= 4) || ($siklusLama >= 3 && $request->tandai_selesai == true);

            return response()->json([
                'success' => true,
                'message' => $isCompleted
                    ? 'Selamat! Anda telah menuntaskan pendampingan pemakaian Eco Enzyme dan kini mandiri 🎉.'
                    : 'Rekap Minggu ke-' . $siklusLama . ' tersimpan. Minggu ke-' . ($siklusLama + 1) . ' telah dimulai.',
                'is_completed' => $isCompleted,
                'next_siklus' => $isCompleted ? $siklusLama : $siklusLama + 1,
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan rekap: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Fitur Pengujian / Simulasi Waktu:
     * Memungkinkan user / tester melompat ke Hari ke-7 (Rekap), Minggu ke-2, Minggu ke-3 (Mandiri / Ulasan), atau Minggu ke-4.
     */
    public function simulateProgress(Request $request)
    {
        $userId = $request->user()?->id ?? auth()->id();
        $trackerId = $request->input('tracker_id');
        $target = $request->input('target'); // 'hari_7', 'minggu_2', 'minggu_3', 'minggu_4', 'reset'

        $query = UserRoutine::query();
        if ($userId) {
            $query->where('user_id', $userId);
        }
        if ($trackerId) {
            $query->where('tracker_id', $trackerId);
        }
        $routines = $query->get();

        if ($routines->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Belum ada rutinitas untuk disimulasikan.',
            ], 404);
        }

        $today = Carbon::today();
        $tglMulaiSelesai = $today->copy()->subDays(6)->toDateString();

        // Pastikan tracker dan routines diaktifkan kembali jika sebelumnya sudah ditandai selesai
        if ($trackerId) {
            ProductTracker::where('id', $trackerId)->update(['status' => 'AKTIF']);
        }

        switch ($target) {
            case 'hari_7':
            case 'minggu_1_hari_7':
                // Minggu 1 Hari ke-7: Evaluasi Rekap Siklus 1 Selesai
                foreach ($routines as $r) {
                    $r->update([
                        'siklus_ke' => 1,
                        'status_rutinitas' => 'AKTIF',
                        'tanggal_mulai_siklus' => $tglMulaiSelesai,
                    ]);
                    for ($d = 0; $d <= 4; $d++) {
                        $checkDate = Carbon::parse($tglMulaiSelesai)->addDays($d)->toDateString();
                        RoutineCheckin::firstOrCreate([
                            'user_routine_id' => $r->id,
                            'siklus_ke' => 1,
                            'tanggal' => $checkDate,
                        ], [
                            'hari_ke' => $d + 1,
                            'waktu' => '19:00',
                        ]);
                    }
                }
                $msg = 'Simulasi aktif: Akhir Minggu ke-1 (Hari ke-7)! Banner & tombol Rekap Siklus 1 aktif 🎉.';
                break;

            case 'minggu_2':
            case 'minggu_2_hari_7':
                // Minggu 2 Hari ke-7: Evaluasi Rekap Siklus 2 Selesai
                foreach ($routines as $r) {
                    $r->update([
                        'siklus_ke' => 2,
                        'status_rutinitas' => 'AKTIF',
                        'tanggal_mulai_siklus' => $tglMulaiSelesai,
                    ]);
                    for ($d = 0; $d <= 4; $d++) {
                        $checkDate = Carbon::parse($tglMulaiSelesai)->addDays($d)->toDateString();
                        RoutineCheckin::firstOrCreate([
                            'user_routine_id' => $r->id,
                            'siklus_ke' => 2,
                            'tanggal' => $checkDate,
                        ], [
                            'hari_ke' => $d + 1,
                            'waktu' => '19:00',
                        ]);
                    }
                }
                $msg = 'Simulasi aktif: Akhir Minggu ke-2 (Hari ke-7)! Banner & tombol Rekap Siklus 2 aktif 🎉.';
                break;

            case 'minggu_3':
            case 'minggu_3_hari_7':
                // Minggu 3: Mandiri & Siap Rekap/Selesai
                foreach ($routines as $r) {
                    $r->update([
                        'siklus_ke' => 3,
                        'status_rutinitas' => 'AKTIF',
                        'tanggal_mulai_siklus' => $tglMulaiSelesai,
                    ]);
                    for ($d = 0; $d <= 4; $d++) {
                        $checkDate = Carbon::parse($tglMulaiSelesai)->addDays($d)->toDateString();
                        RoutineCheckin::firstOrCreate([
                            'user_routine_id' => $r->id,
                            'siklus_ke' => 3,
                            'tanggal' => $checkDate,
                        ], [
                            'hari_ke' => $d + 1,
                            'waktu' => '19:00',
                        ]);
                    }
                }
                $msg = 'Simulasi aktif: Akhir Minggu ke-3! Anda Sudah Mandiri 🌟 & berhak Ulasan Terverifikasi.';
                break;

            case 'minggu_4':
            case 'minggu_4_hari_7':
                // Minggu 4: Siklus Terakhir
                foreach ($routines as $r) {
                    $r->update([
                        'siklus_ke' => 4,
                        'status_rutinitas' => 'AKTIF',
                        'tanggal_mulai_siklus' => $tglMulaiSelesai,
                    ]);
                    for ($d = 0; $d <= 4; $d++) {
                        $checkDate = Carbon::parse($tglMulaiSelesai)->addDays($d)->toDateString();
                        RoutineCheckin::firstOrCreate([
                            'user_routine_id' => $r->id,
                            'siklus_ke' => 4,
                            'tanggal' => $checkDate,
                        ], [
                            'hari_ke' => $d + 1,
                            'waktu' => '19:00',
                        ]);
                    }
                }
                $msg = 'Simulasi aktif: Akhir Minggu ke-4! Fase terakhir sebelum selesai mandiri.';
                break;

            case 'reset':
            default:
                foreach ($routines as $r) {
                    $r->update([
                        'siklus_ke' => 1,
                        'status_rutinitas' => 'AKTIF',
                        'tanggal_mulai_siklus' => $today->toDateString(),
                    ]);
                }
                $msg = 'Progres simulasi di-reset ke Minggu 1 Hari 1 (Awal Siklus).';
                break;
        }

        return response()->json([
            'success' => true,
            'message' => $msg,
            'target' => $target,
        ]);
    }
}
