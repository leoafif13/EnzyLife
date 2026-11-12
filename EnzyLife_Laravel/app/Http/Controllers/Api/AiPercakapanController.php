<?php

namespace App\Http\Controllers\Api;

use App\Models\AiPesan;
use Illuminate\Support\Facades\Http;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\AiPercakapan;
use Illuminate\Support\Facades\DB;

class AiPercakapanController extends Controller
{
    public function index(Request $request)
    {
        $percakapan = $request->user()
            ->aiPercakapan()
            ->where('disimpan', true)
            ->withCount('pesan')
            ->orderByDesc('updated_at')
            ->get();

        return response()->json([
            'data' => $percakapan,
            'jumlah_disimpan' => $percakapan->count(),
            'maksimal_disimpan' => 3,
        ]);
    }

    public function store(Request $request)
    {
        $percakapan = $request->user()
            ->aiPercakapan()
            ->create([
                'judul' => 'Percakapan Baru',
                'disimpan' => false,
            ]);

        return response()->json([
            'message' => 'Percakapan baru berhasil dibuat.',
            'data' => $percakapan,
        ], 201);
    }
    
    
    public function sendMessage(Request $request, int $id)
    {
        $validated = $request->validate([
            'pertanyaan' => 'required|string|max:2000',
        ]);

        $pertanyaan = trim($validated['pertanyaan']);

        if ($pertanyaan === '') {
            return response()->json([
                'message' => 'Pertanyaan tidak boleh kosong.',
            ], 422);
        }

        // Pastikan percakapan milik pengguna yang login.
        $percakapan = $request->user()
            ->aiPercakapan()
            ->where('id_percakapan', $id)
            ->firstOrFail();

        // Ambil riwayat percakapan sebelumnya.
        $history = $percakapan->pesan()
            ->orderBy('created_at')
            ->get()
            ->map(function ($pesan) {
                return [
                    'role' => $pesan->peran,
                    'content' => $pesan->isi,
                ];
            })
            ->values()
            ->all();

        try {
            // Panggil layanan AI sebelum menyimpan pesan.
            $response = Http::connectTimeout(10)
                ->timeout(180)
                ->post('http://127.0.0.1:8001/chat', [
                    'pertanyaan' => $pertanyaan,
                    'history' => $history,
                ]);

            if (!$response->successful()) {
                return response()->json([
                    'message' => 'Layanan AI gagal memproses pertanyaan.',
                ], 502);
            }

            $jawaban = $response->json('jawaban');

            if (!is_string($jawaban) || trim($jawaban) === '') {
                return response()->json([
                    'message' => 'Layanan AI tidak memberikan jawaban yang valid.',
                ], 502);
            }

            // Jangan simpan respons fallback sebagai jawaban sukses.
            if (
                str_contains(
                    $jawaban,
                    'layanan konsultasi EnzyLife sedang mengalami gangguan'
                )
            ) {
                return response()->json([
                    'message' => 'Layanan AI sedang mengalami gangguan. Silakan coba lagi.',
                ], 502);
            }

            // Simpan pertanyaan dan jawaban dalam satu transaksi.
            DB::transaction(function () use (
                $percakapan,
                $pertanyaan,
                $jawaban
            ) {
                $percakapan->pesan()->create([
                    'peran' => 'user',
                    'isi' => $pertanyaan,
                ]);

                $percakapan->pesan()->create([
                    'peran' => 'assistant',
                    'isi' => $jawaban,
                ]);

                $percakapan->touch();
            });

            return response()->json([
                'message' => 'Pesan berhasil diproses.',
                'pertanyaan' => $pertanyaan,
                'jawaban' => $jawaban,
                'id_percakapan' => $percakapan->id_percakapan,
            ]);

        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            return response()->json([
                'message' => 'Tidak dapat terhubung ke layanan AI EnzyLife.',
            ], 502);

        } catch (\Throwable $e) {
            report($e);

            return response()->json([
                'message' => 'Terjadi kesalahan saat memproses percakapan.',
            ], 500);
        }
    }

    public function show(Request $request, int $id)
    {
        $percakapan = $request->user()
            ->aiPercakapan()
            ->with('pesan')
            ->where('id_percakapan', $id)
            ->firstOrFail();

        return response()->json([
            'data' => $percakapan,
        ]);
    }


    public function save(Request $request, int $id)
    {
        $percakapan = $request->user()
            ->aiPercakapan()
            ->where('id_percakapan', $id)
            ->firstOrFail();

        if ($percakapan->disimpan) {
            return response()->json([
                'message' => 'Percakapan ini sudah tersimpan.',
                'data' => $percakapan,
            ]);
        }

        $jumlahDisimpan = $request->user()
            ->aiPercakapan()
            ->where('disimpan', true)
            ->count();

        if ($jumlahDisimpan >= 3) {
            return response()->json([
                'message' => 'Maksimal 3 percakapan tersimpan. Hapus salah satu percakapan terlebih dahulu.',
                'jumlah_disimpan' => $jumlahDisimpan,
                'maksimal_disimpan' => 3,
            ], 422);
        }

        $percakapan->disimpan = true;

        // Gunakan pesan pertama sebagai judul percakapan.
        $pesanPertama = $percakapan->pesan()
            ->where('peran', 'user')
            ->orderBy('created_at')
            ->first();

        if ($pesanPertama) {
            $percakapan->judul = \Illuminate\Support\Str::limit(
                $pesanPertama->isi,
                60
            );
        }

        $percakapan->save();

        return response()->json([
            'message' => 'Percakapan berhasil disimpan.',
            'data' => $percakapan,
            'jumlah_disimpan' => $jumlahDisimpan + 1,
            'maksimal_disimpan' => 3,
        ]);
    }

    public function destroy(Request $request, int $id)
    {
        $percakapan = $request->user()
            ->aiPercakapan()
            ->where('id_percakapan', $id)
            ->firstOrFail();

        $percakapan->delete();

        return response()->json([
            'message' => 'Percakapan berhasil dihapus.',
        ]);
    }

    
    public function feedback(Request $request, int $id)
    {
        $validated = $request->validate([
            'feedback' => 'required|in:membantu,tidak_membantu',
        ]);

        $percakapan = $request->user()
            ->aiPercakapan()
            ->where('id_percakapan', $id)
            ->firstOrFail();

        $percakapan->feedback = $validated['feedback'];
        $percakapan->save();

        return response()->json([
            'message' => 'Feedback berhasil disimpan.',
            'data' => [
                'id_percakapan' => $percakapan->id_percakapan,
                'feedback' => $percakapan->feedback,
            ],
        ]);
    }

}
