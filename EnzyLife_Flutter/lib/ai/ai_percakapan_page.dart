
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../services/api_service.dart';

class AiPercakapanPage extends StatefulWidget {
  const AiPercakapanPage({super.key});

  @override
  State<AiPercakapanPage> createState() => _AiPercakapanPageState();
}

class _AiPercakapanPageState extends State<AiPercakapanPage> {
  static const String _keyIdPercakapanAktif =
      'ai_active_conversation_id';
  static const int _maksimalSimpan = 3;

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _pesan = [];

  int? _idPercakapan;
  bool _sedangMemproses = false;
  bool _memuatRiwayat = true;
  bool _mengirimFeedback = false;
  bool _menyimpanPercakapan = false;

  bool? _feedbackMembantu;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _pulihkanPercakapan();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pulihkanPercakapan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt(_keyIdPercakapanAktif);

      if (id == null) {
        if (mounted) {
          setState(() => _memuatRiwayat = false);
        }
        return;
      }

      await _bukaPercakapan(id, tampilkanError: false);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _memuatRiwayat = false;
        _pesanError = 'Riwayat chat gagal dimuat.';
      });
    }
  }

  Future<int> _buatPercakapanBaru() async {
    final response = await ApiService.createAiConversation();

    if (response == null) {
      throw Exception('Gagal membuat percakapan baru.');
    }

    final dynamic data = response['data'];
    int? id;

    if (data is Map) {
      id = int.tryParse(
        '${data['id'] ?? data['id_percakapan'] ?? ''}',
      );
    }

    id ??= int.tryParse(
      '${response['id'] ?? response['id_percakapan'] ?? ''}',
    );

    if (id == null) {
      throw Exception('ID percakapan tidak ditemukan.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyIdPercakapanAktif, id);

    if (!mounted) return id;

    setState(() {
      _idPercakapan = id;
      _feedbackMembantu = null;
    });

    return id;
  }

  Future<void> _kirimPesan() async {
    final teks = _controller.text.trim();

    if (teks.isEmpty ||
        _sedangMemproses ||
        _memuatRiwayat ||
        _menyimpanPercakapan ||
        _mengirimFeedback) {
      return;
    }

    _controller.clear();

    setState(() {
      _pesanError = null;
      _sedangMemproses = true;
      _pesan.add({'peran': 'user', 'isi': teks});
    });

    _gulirKeBawah();

    try {
      final id = _idPercakapan ?? await _buatPercakapanBaru();

      final response = await ApiService.sendAiMessage(
        conversationId: id,
        pertanyaan: teks,
      );

      if (response == null) {
        throw Exception('Tidak ada respons dari server.');
      }

      if (response['success'] == false) {
        throw Exception(
          response['message'] ?? 'Pesan gagal dikirim.',
        );
      }

      final dynamic data = response['data'];
      final jawaban = (
        response['jawaban'] ??
        (data is Map ? data['jawaban'] : null) ??
        ''
      ).toString();

      if (jawaban.trim().isEmpty) {
        throw Exception('Jawaban AI kosong.');
      }

      if (!mounted) return;

      setState(() {
        _pesan.add({'peran': 'assistant', 'isi': jawaban});
      });

      _gulirKeBawah();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _pesanError =
            'Pesan gagal dikirim. Periksa koneksi dan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() => _sedangMemproses = false);
      }
    }
  }

  Future<void> _bukaPercakapan(
    int id, {
    bool tampilkanError = true,
  }) async {
    if (_sedangMemproses ||
        _mengirimFeedback ||
        _menyimpanPercakapan) {
      return;
    }

    setState(() {
      _memuatRiwayat = true;
      _pesanError = null;
    });

    try {
      final response = await ApiService.getAiConversationDetail(id);

      if (response == null) {
        throw Exception('Detail percakapan gagal dimuat.');
      }

      final dynamic data = response['data'];
      if (data is! Map) {
        throw Exception('Format detail percakapan tidak valid.');
      }

      final percakapan = Map<String, dynamic>.from(data);
      final dynamic daftarPesan = percakapan['pesan'];
      final List<Map<String, dynamic>> pesanTersimpan = [];

      if (daftarPesan is List) {
        for (final item in daftarPesan) {
          if (item is! Map) continue;

          final pesan = Map<String, dynamic>.from(item);
          final peran = (pesan['peran'] ??
                  pesan['role'] ??
                  pesan['pengirim'] ??
                  '')
              .toString()
              .toLowerCase();

          final isi = (pesan['isi'] ??
                  pesan['pesan'] ??
                  pesan['konten'] ??
                  pesan['content'] ??
                  '')
              .toString();

          if (isi.trim().isEmpty) continue;

          final dariPengguna = [
            'user',
            'pengguna',
            'human',
            'user_message',
          ].contains(peran);

          pesanTersimpan.add({
            'peran': dariPengguna ? 'user' : 'assistant',
            'isi': isi,
          });
        }
      }

      final feedback = percakapan['feedback']?.toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyIdPercakapanAktif, id);

      if (!mounted) return;

      setState(() {
        _idPercakapan = id;
        _pesan
          ..clear()
          ..addAll(pesanTersimpan);

        _feedbackMembantu = feedback == 'membantu'
            ? true
            : feedback == 'tidak_membantu'
                ? false
                : null;

        _memuatRiwayat = false;
      });

      _gulirKeBawah();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _memuatRiwayat = false;
        if (tampilkanError) {
          _pesanError = 'Percakapan gagal dibuka. Coba lagi.';
        }
      });
    }
  }

  Future<List<Map<String, dynamic>>?> _ambilDaftarTersimpan() async {
    final response = await ApiService.getAiConversations();
    if (response == null) return null;

    final dynamic data = response['data'];
    if (data is! List) return [];

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> _tampilkanPercakapanTersimpan() async {
    if (_sedangMemproses ||
        _mengirimFeedback ||
        _menyimpanPercakapan ||
        _memuatRiwayat) {
      return;
    }

    final daftar = await _ambilDaftarTersimpan();

    if (!mounted) return;

    if (daftar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daftar percakapan gagal dimuat.'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text(
                        'Percakapan Tersimpan',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${daftar.length}/$_maksimalSimpan percakapan tersimpan',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: daftar.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'Belum ada percakapan tersimpan.\n'
                                  'Simpan percakapan agar mudah dibuka kembali.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: daftar.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final item = daftar[index];
                                final id = int.tryParse(
                                  '${item['id'] ?? item['id_percakapan'] ?? ''}',
                                );

                                final judul =
                                    (item['judul'] ?? 'Percakapan Eco Enzyme')
                                        .toString();

                                final dynamic jumlahPesanData =
                                    item['pesan_count'] ??
                                    item['pesan_count_count'] ??
                                    item['jumlah_pesan'];

                                final int jumlahPesan;
                                if (jumlahPesanData is num) {
                                  jumlahPesan = jumlahPesanData.toInt();
                                } else if (item['pesan'] is List) {
                                  jumlahPesan =
                                      (item['pesan'] as List).length;
                                } else {
                                  jumlahPesan = 0;
                                }

                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.chat_bubble_outline),
                                  ),
                                  title: Text(
                                    judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text('$jumlahPesan pesan'),
                                  trailing: IconButton(
                                    tooltip: 'Hapus percakapan',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: id == null
                                        ? null
                                        : () async {
                                            final hapus =
                                                await _konfirmasiHapus(id);

                                            if (hapus != true ||
                                                !mounted) {
                                              return;
                                            }

                                            final hasil =
                                                await ApiService
                                                    .deleteAiConversation(id);

                                            if (!mounted) return;

                                            if (hasil == null ||
                                                hasil['success'] != true) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Percakapan gagal dihapus.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            if (_idPercakapan == id) {
                                              await _mulaiPercakapanBaru();
                                            }

                                            setSheetState(() {
                                              daftar.removeAt(index);
                                            });

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Percakapan berhasil dihapus.',
                                                ),
                                              ),
                                            );
                                          },
                                  ),
                                  onTap: id == null
                                      ? null
                                      : () {
                                          Navigator.pop(sheetContext);
                                          _bukaPercakapan(id);
                                        },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _konfirmasiHapus(int id) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Percakapan?'),
        content: const Text(
          'Percakapan ini akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<bool> _simpanPercakapan() async {
    if (_idPercakapan == null ||
        _pesan.isEmpty ||
        _sedangMemproses ||
        _mengirimFeedback ||
        _menyimpanPercakapan) {
      return false;
    }

    setState(() {
      _menyimpanPercakapan = true;
      _pesanError = null;
    });

    try {
      final daftar = await _ambilDaftarTersimpan();

      if (daftar == null) {
        throw Exception('Gagal memeriksa daftar percakapan.');
      }

      final sudahTersimpan = daftar.any((item) {
        final id = int.tryParse(
          '${item['id'] ?? item['id_percakapan'] ?? ''}',
        );
        return id == _idPercakapan;
      });

      if (sudahTersimpan) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Percakapan ini sudah tersimpan.'),
            ),
          );
        }
        return true;
      }

      if (daftar.length >= _maksimalSimpan) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Maksimal 3 percakapan tersimpan. Hapus salah satunya '
                'dari daftar riwayat terlebih dahulu.',
              ),
            ),
          );
        }
        return false;
      }

      final response =
          await ApiService.saveAiConversation(_idPercakapan!);

      if (response == null || response['success'] != true) {
        throw Exception(
          response?['message'] ?? 'Percakapan gagal disimpan.',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Percakapan berhasil disimpan.'),
          ),
        );
      }

      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan percakapan. Coba lagi.'),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _menyimpanPercakapan = false);
      }
    }
  }

  Future<void> _kirimFeedback(bool membantu) async {
    if (_idPercakapan == null ||
        _feedbackMembantu != null ||
        _mengirimFeedback ||
        _sedangMemproses) {
      return;
    }

    setState(() {
      _mengirimFeedback = true;
      _pesanError = null;
    });

    try {
      final response = await ApiService.sendAiFeedback(
        conversationId: _idPercakapan!,
        membantu: membantu,
      );

      if (response == null || response['success'] != true) {
        throw Exception('Feedback gagal dikirim.');
      }

      if (!mounted) return;

      setState(() => _feedbackMembantu = membantu);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih atas feedback kamu!'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback gagal dikirim. Coba lagi.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _mengirimFeedback = false);
      }
    }
  }

  Future<void> _percakapanBaru() async {
    if (_sedangMemproses ||
        _mengirimFeedback ||
        _menyimpanPercakapan ||
        _memuatRiwayat) {
      return;
    }

    if (_pesan.isEmpty || _idPercakapan == null) {
      await _mulaiPercakapanBaru();
      return;
    }

    final pilihan = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mulai Percakapan Baru?'),
        content: const Text(
          'Percakapan saat ini akan ditinggalkan. '
          'Apakah kamu ingin menyimpannya agar bisa dibuka kembali?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'batal'),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, 'tanpa_simpan'),
            child: const Text('Tanpa Menyimpan'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'simpan'),
            child: const Text('Simpan & Baru'),
          ),
        ],
      ),
    );

    if (!mounted || pilihan == null || pilihan == 'batal') return;

    if (pilihan == 'simpan') {
      final berhasil = await _simpanPercakapan();
      if (berhasil) {
        await _mulaiPercakapanBaru();
      }
      return;
    }

    if (pilihan == 'tanpa_simpan') {
      final id = _idPercakapan;

      if (id != null) {
        final hasil = await ApiService.deleteAiConversation(id);

        if (hasil == null || hasil['success'] != true) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Percakapan gagal dihapus. Silakan coba lagi.',
              ),
            ),
          );
          return;
        }
      }

      await _mulaiPercakapanBaru();
    }
  }

  Future<void> _mulaiPercakapanBaru() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIdPercakapanAktif);

    if (!mounted) return;

    setState(() {
      _idPercakapan = null;
      _pesan.clear();
      _feedbackMembantu = null;
      _pesanError = null;
      _controller.clear();
    });
  }

  void _gulirKeBawah() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const hijau = Color(0xFF2E7D32);
    const hijauMuda = Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: hijau,
        elevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EnzyLife Assistant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Konsultasi seputar Eco Enzyme',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Percakapan tersimpan',
            onPressed: _tampilkanPercakapanTersimpan,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'Percakapan baru',
            onPressed: _percakapanBaru,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: hijauMuda,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.eco_outlined, color: hijau),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tanyakan informasi tentang Eco Enzyme, '
                      'manfaat, cara pembuatan, dan penggunaannya.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _memuatRiwayat
                  ? const Center(
                      child: CircularProgressIndicator(color: hijau),
                    )
                  : _pesan.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 54,
                                  color: hijau,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Halo! Ada yang ingin kamu ketahui '
                                  'tentang Eco Enzyme?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Ketik pertanyaanmu di bawah untuk '
                                  'memulai konsultasi.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            16,
                          ),
                          itemCount: _pesan.length +
                              (_sedangMemproses ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_sedangMemproses &&
                                index == _pesan.length) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: hijau,
                                    ),
                                  ),
                                ),
                              );
                            }

                            final pesan = _pesan[index];
                            final dariPengguna =
                                pesan['peran'] == 'user';

                            return Align(
                              alignment: dariPengguna
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width *
                                          0.82,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: dariPengguna
                                      ? hijau
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: dariPengguna
                                  ? Text(
                                      pesan['isi']?.toString() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        height: 1.45,
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: pesan['isi']?.toString() ?? '',
                                      selectable: true,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          height: 1.45,
                                        ),
                                        strong: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        listBullet: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                              ),
                            );
                          },
                        ),
            ),
            if (_pesanError != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Text(
                  _pesanError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_pesan.isNotEmpty && !_sedangMemproses)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Apakah jawaban ini membantu?',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Simpan percakapan',
                      onPressed: _menyimpanPercakapan
                          ? null
                          : () async {
                              await _simpanPercakapan();
                            },
                      icon: _menyimpanPercakapan
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.bookmark_add_outlined),
                    ),
                    IconButton(
                      tooltip: _feedbackMembantu == true
                          ? 'Feedback sudah dikirim'
                          : 'Membantu',
                      onPressed: _feedbackMembantu != null ||
                              _mengirimFeedback
                          ? null
                          : () => _kirimFeedback(true),
                      icon: Icon(
                        Icons.thumb_up_alt_outlined,
                        color: _feedbackMembantu == true
                            ? hijau
                            : Colors.grey,
                      ),
                    ),
                    IconButton(
                      tooltip: _feedbackMembantu == false
                          ? 'Feedback sudah dikirim'
                          : 'Tidak membantu',
                      onPressed: _feedbackMembantu != null ||
                              _mengirimFeedback
                          ? null
                          : () => _kirimFeedback(false),
                      icon: Icon(
                        Icons.thumb_down_alt_outlined,
                        color: _feedbackMembantu == false
                            ? Colors.red
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE5E5E5)),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 2000,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _kirimPesan(),
                      decoration: InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sedangMemproses || _memuatRiwayat
                        ? null
                        : _kirimPesan,
                    style: IconButton.styleFrom(
                      backgroundColor: hijau,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
