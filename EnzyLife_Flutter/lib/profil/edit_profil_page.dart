import 'package:flutter/material.dart';
import '../app_color.dart';
import '../widgets/sub_page_appbar.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {

  UserModel? user;

  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kodePosController = TextEditingController();

  bool _isLoading = false;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isProfileLoading = true);
    final result = await ApiService.getProfile();

    if (!mounted) return;

    if (result == null) {
      setState(() => _isProfileLoading = false);
      return;
    }

    setState(() {
      user = result;
      _namaController.text = result.name;
      _emailController.text = result.email;
      _noHpController.text = result.phone ?? '';
      _alamatController.text = result.address ?? '';
      _kodePosController.text = result.postalCode ?? '';
      _isProfileLoading = false;
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    _kodePosController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    final cleanName = _namaController.text.trim();
    if (cleanName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nama Lengkap tidak boleh kosong'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (cleanName == 'Pengguna Baru' || cleanName == '-') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Silakan masukkan nama lengkap asli Anda'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final phone = _noHpController.text.trim();
    if (phone.isNotEmpty) {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.length < 10 || cleanPhone.length > 15) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Nomor HP tidak valid (minimal 10 digit, maksimal 15 digit)'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    final zip = _kodePosController.text.trim();
    if (zip.isNotEmpty) {
      if (zip.length != 5 || int.tryParse(zip) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Kode pos harus terdiri dari 5 digit angka'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final success = await ApiService.updateProfile(
      name: cleanName,
      phone: _noHpController.text,
      address: _alamatController.text,
      postalCode: _kodePosController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal memperbarui profil di server. Silakan coba lagi.'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    await ApiService.getProfile();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui'),
        backgroundColor: AppColors.green500,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  String getInitials(String name) {
    final words = name.trim().split(' ');

    if (words.length >= 2) {
      return words[0][0].toUpperCase() +
          words[1][0].toUpperCase();
    }

    if (words.isNotEmpty && words[0].isNotEmpty) {
      return words[0][0].toUpperCase();
    }

    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: const SubPageAppBar(title: 'Edit Profil'),
      body: _isProfileLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.green500),
                    SizedBox(height: 16),
                    Text(
                      'Memuat profil Anda...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.green900,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.green500, AppColors.green700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getInitials(user?.name ?? ''),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.green500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 15, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Ketuk untuk ganti foto',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),

            const SizedBox(height: 28),

            // Form
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Masukkan email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _noHpController,
                    label: 'Nomor HP',
                    hint: 'Masukkan nomor HP',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _alamatController,
                    label: 'Alamat',
                    hint: 'Masukkan alamat',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    controller: _kodePosController,
                    label: 'Kode Pos',
                    hint: 'Masukkan kode pos',
                    icon: Icons.markunread_mailbox_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.green500.withOpacity(0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Simpan Perubahan',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool readOnly;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: AppColors.green900, letterSpacing: 0.1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(fontSize: 14, color: AppColors.text1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.green500, size: 20),
            filled: true,
            fillColor: AppColors.green50,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.green500, width: 1.5)),
          ),
        ),
      ],
    );
  }
}