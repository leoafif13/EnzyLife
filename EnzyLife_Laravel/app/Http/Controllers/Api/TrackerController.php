<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ProductTracker;
use App\Models\TrackerLog;
use App\Models\Pemesanan;
use Carbon\Carbon;

class TrackerController extends Controller
{
    /**
     * Mulai tracking produk baru (3 minggu default).
     */
    public function store(Request $request)
    {
        $request->validate([
            'pemesanan_id' => 'required|exists:pemesanan,id',
            'produk_id' => 'required|exists:products,id',
        ]);

        $pemesanan = Pemesanan::findOrFail($request->pemesanan_id);

        // Harus milik user login
        if ($pemesanan->user_id != auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan tidak ditemukan',
            ], 403);
        }

        // Harus selesai
        if ($pemesanan->status_pemesanan !== 'SELESAI') {
            return response()->json([
                'success' => false,
                'message' => 'Pesanan belum selesai',
            ], 400);
        }

        // Verifikasi produk adalah bagian dari pesanan
        $hasProduct = $pemesanan->detailPemesanan()
            ->where('produk_id', $request->produk_id)
            ->exists();

        if (!$hasProduct) {
            return response()->json([
                'success' => false,
                'message' => 'Produk tidak ditemukan dalam pesanan ini',
            ], 400);
        }

        // Cek apakah user sudah punya tracker untuk produk ini (di pesanan ini atau pesanan sebelumnya)
        $existing = ProductTracker::where('user_id', auth()->id())
            ->where('produk_id', $request->produk_id)
            ->first();

        if ($existing) {
            $isSameOrder = $existing->pemesanan_id == $request->pemesanan_id;
            return response()->json([
                'success' => false,
                'already_tracked' => true,
                'message' => $isSameOrder
                    ? 'Tracker untuk produk ini sudah dibuat'
                    : 'Anda sudah pernah memiliki tracker untuk produk ini sebelumnya',
                'data' => $existing,
            ], 409);
        }

        $tanggalMulai = Carbon::today();

        $tracker = ProductTracker::create([
            'user_id' => auth()->id(),
            'pemesanan_id' => $request->pemesanan_id,
            'produk_id' => $request->produk_id,
            'tanggal_mulai' => $tanggalMulai,
            'tanggal_selesai' => $tanggalMulai->copy()->addWeeks(3),
            'status' => 'AKTIF',
        ]);

        $tracker->load('produk');

        return response()->json([
            'success' => true,
            'message' => 'Tracker berhasil dimulai (3 minggu)',
            'data' => $tracker,
        ], 201);
    }

    /**
     * List semua tracker milik user (aktif & selesai).
     */
    public function index()
    {
        $trackers = ProductTracker::where('user_id', auth()->id())
            ->with(['produk', 'pemesanan'])
            ->withCount('logs')
            ->orderByDesc('created_at')
            ->get()
            ->map(function ($tracker) {
                $tracker->hari_ke = $tracker->hari_ke;
                $tracker->batas_akhir = $tracker->batas_akhir;
                return $tracker;
            });

        return response()->json([
            'success' => true,
            'data' => $trackers,
        ]);
    }

    /**
     * Detail tracker + logs + statistik.
     */
    public function show($id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->with(['produk', 'pemesanan', 'logs' => function ($q) {
                $q->orderByDesc('tanggal')->orderByDesc('waktu');
            }])
            ->withCount('logs')
            ->findOrFail($id);

        // Hitung statistik
        $totalHari = (int) $tracker->tanggal_mulai->diffInDays($tracker->batas_akhir);
        $hariKe = (int) $tracker->hari_ke;
        $totalLogs = (int) $tracker->logs_count;

        // Logs per minggu
        $logsPerMinggu = $tracker->logs
            ->groupBy(function ($log) use ($tracker) {
                $mingguKe = (int) ceil(
                    ((int) $tracker->tanggal_mulai->diffInDays($log->tanggal) + 1) / 7
                );
                return "Minggu $mingguKe";
            })
            ->map->count();

        return response()->json([
            'success' => true,
            'data' => $tracker,
            'stats' => [
                'hari_ke' => $hariKe,
                'total_hari' => $totalHari,
                'total_logs' => $totalLogs,
                'progres_persen' => $totalHari > 0
                    ? round(($hariKe / $totalHari) * 100, 1)
                    : 0,
                'sudah_minggu_ke_tiga' => $tracker->isSudahMingguKeTiga(),
                'bisa_perpanjang' => $tracker->status === 'AKTIF'
                    && $tracker->isSudahMingguKeTiga()
                    && is_null($tracker->tanggal_perpanjangan),
                'logs_per_minggu' => $logsPerMinggu,
            ],
        ]);
    }

    /**
     * Tambah log pemakaian harian.
     */
    public function storeLog(Request $request, $id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        if (!$tracker->isMasihAktif()) {
            return response()->json([
                'success' => false,
                'message' => 'Tracker sudah tidak aktif',
            ], 400);
        }

        $request->validate([
            'tanggal' => 'required|date',
            'waktu' => 'required|date_format:H:i',
            'catatan' => 'nullable|string|max:500',
        ]);

        $log = TrackerLog::create([
            'tracker_id' => $tracker->id,
            'tanggal' => $request->tanggal,
            'waktu' => $request->waktu,
            'catatan' => $request->catatan,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Log pemakaian berhasil dicatat',
            'data' => $log,
        ], 201);
    }

    /**
     * List semua log per tracker.
     */
    public function getLogs($id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        $logs = $tracker->logs()
            ->orderByDesc('tanggal')
            ->orderByDesc('waktu')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $logs,
        ]);
    }

    /**
     * Hapus log tertentu.
     */
    public function deleteLog($id, $logId)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        $log = $tracker->logs()->findOrFail($logId);
        $log->delete();

        return response()->json([
            'success' => true,
            'message' => 'Log berhasil dihapus',
        ]);
    }

    /**
     * Perpanjang tracking (max +2 minggu, total max 5 minggu).
     */
    public function perpanjang(Request $request, $id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        if ($tracker->status !== 'AKTIF') {
            return response()->json([
                'success' => false,
                'message' => 'Hanya tracker aktif yang bisa diperpanjang',
            ], 400);
        }

        if (!$tracker->isSudahMingguKeTiga()) {
            return response()->json([
                'success' => false,
                'message' => 'Perpanjangan baru bisa dilakukan setelah minggu ke-3',
            ], 400);
        }

        if ($tracker->tanggal_perpanjangan) {
            return response()->json([
                'success' => false,
                'message' => 'Tracker sudah diperpanjang sebelumnya',
            ], 400);
        }

        $request->validate([
            'durasi_tambahan_minggu' => 'required|integer|min:1|max:2',
        ]);

        $tambahan = $request->durasi_tambahan_minggu;
        $tanggalPerpanjangan = $tracker->tanggal_selesai
            ->copy()
            ->addWeeks($tambahan);

        // Validasi max 5 minggu total dari tanggal mulai
        $maxAkhir = $tracker->tanggal_mulai->copy()->addWeeks(5);
        if ($tanggalPerpanjangan->gt($maxAkhir)) {
            $tanggalPerpanjangan = $maxAkhir;
        }

        $tracker->update([
            'tanggal_perpanjangan' => $tanggalPerpanjangan,
            'status' => 'PERPANJANGAN',
        ]);

        return response()->json([
            'success' => true,
            'message' => "Tracker diperpanjang {$tambahan} minggu",
            'data' => $tracker->fresh(),
        ]);
    }

    /**
     * Selesaikan tracking + isi catatan hasil.
     */
    public function selesai(Request $request, $id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        if (!in_array($tracker->status, ['AKTIF', 'PERPANJANGAN'])) {
            return response()->json([
                'success' => false,
                'message' => 'Tracker sudah selesai atau dibatalkan',
            ], 400);
        }

        $request->validate([
            'catatan_hasil' => 'nullable|string|max:1000',
        ]);

        $tracker->update([
            'catatan_hasil' => $request->catatan_hasil,
            'status' => 'SELESAI',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Tracking selesai! Silakan tulis ulasan terverifikasi.',
            'data' => $tracker->fresh(),
        ]);
    }

    /**
     * Batalkan tracking.
     */
    public function batalkan($id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->findOrFail($id);

        if (!in_array($tracker->status, ['AKTIF', 'PERPANJANGAN'])) {
            return response()->json([
                'success' => false,
                'message' => 'Tracker sudah selesai atau dibatalkan',
            ], 400);
        }

        $tracker->update([
            'status' => 'DIBATALKAN',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Tracking dibatalkan',
        ]);
    }

    /**
     * Data statistik untuk chart.
     */
    public function stats($id)
    {
        $tracker = ProductTracker::where('user_id', auth()->id())
            ->with('logs')
            ->withCount('logs')
            ->findOrFail($id);

        $totalHari = (int) $tracker->tanggal_mulai->diffInDays($tracker->batas_akhir);
        $hariKe = min((int) $tracker->hari_ke, $totalHari);

        // Logs per hari (untuk chart bar/line)
        $logsPerHari = $tracker->logs
            ->groupBy(fn ($log) => $log->tanggal->format('Y-m-d'))
            ->map->count()
            ->sortKeys();

        // Logs per minggu
        $logsPerMinggu = $tracker->logs
            ->groupBy(function ($log) use ($tracker) {
                $mingguKe = (int) ceil(
                    ((int) $tracker->tanggal_mulai->diffInDays($log->tanggal) + 1) / 7
                );
                return "Minggu $mingguKe";
            })
            ->map->count();

        // Streak: hari berturut-turut yang ada log-nya
        $hariDenganLog = $tracker->logs
            ->pluck('tanggal')
            ->map(fn ($d) => $d->format('Y-m-d'))
            ->unique()
            ->sort()
            ->values();

        $streak = 0;
        $maxStreak = 0;
        $prevDate = null;

        foreach ($hariDenganLog as $dateStr) {
            $date = Carbon::parse($dateStr);
            if ($prevDate && (int) $date->diffInDays($prevDate) === 1) {
                $streak++;
            } else {
                $streak = 1;
            }
            $maxStreak = max($maxStreak, $streak);
            $prevDate = $date;
        }

        // Streak aktif: hanya jika log terakhir adalah hari ini atau kemarin
        $lastLogDate = $hariDenganLog->last();
        $isStreakActive = $lastLogDate && (int) Carbon::parse($lastLogDate)->startOfDay()->diffInDays(today()) <= 1;
        $currentStreak = $isStreakActive ? $streak : 0;

        return response()->json([
            'success' => true,
            'data' => [
                'hari_ke' => (int) $tracker->hari_ke,
                'total_hari' => $totalHari,
                'total_logs' => (int) $tracker->logs_count,
                'progres_persen' => $totalHari > 0
                    ? round(($hariKe / $totalHari) * 100, 1)
                    : 0,
                'streak_saat_ini' => $currentStreak,
                'streak_terpanjang' => $maxStreak,
                'logs_per_hari' => $logsPerHari,
                'logs_per_minggu' => $logsPerMinggu,
            ],
        ]);
    }
}
