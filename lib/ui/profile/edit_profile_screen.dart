import 'dart:io'; // Buat File
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Plugin baru

// Import Model & Services
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../services/storage_services.dart'; // Jangan lupa import ini (namanya sesuaikan dengan file kamu, kadang storage_service.dart atau storage_services.dart)

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _majorController = TextEditingController();

  bool _isLoading = false;
  File? _pickedImage; // File foto baru yang dipilih dari galeri
  String? _currentPhotoUrl; // URL foto lama dari database (untuk preview)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final userAuth = Provider.of<User?>(context, listen: false);
    if (userAuth != null) {
      UserModel? userData = await DatabaseService(
        uid: userAuth.uid,
      ).getUserData();

      if (userData != null && mounted) {
        setState(() {
          _nameController.text = userData.name;
          _nimController.text = userData.nim;
          _majorController.text = userData.major;
          _currentPhotoUrl = userData.photoUrl; // Simpan URL foto lama
        });
      }
    }
  }

  // LOGIC 1: AMBIL FOTO DARI GALERI
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final userAuth = Provider.of<User?>(context, listen: false);
    if (userAuth == null) return;

    if (_nameController.text.isEmpty ||
        _nimController.text.isEmpty ||
        _majorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data harus diisi")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? newPhotoUrl = _currentPhotoUrl; // Default: pakai foto lama

      // LOGIC 2: UPLOAD FOTO (Jika user memilih foto baru)
      if (_pickedImage != null) {
        // Panggil StorageService yang baru kita buat
        // Pastikan nama filenya 'storage_service.dart' atau sesuaikan import di atas
        newPhotoUrl = await StorageService().uploadProfileImage(
          _pickedImage!,
          userAuth.uid,
        );
      }

      // 3. Update ke Firestore
      // Ambil data lama untuk mempertahankan token FCM
      UserModel? existingData = await DatabaseService(
        uid: userAuth.uid,
      ).getUserData();

      await DatabaseService(uid: userAuth.uid).updateUserData(
        UserModel(
          uid: userAuth.uid,
          email: userAuth.email ?? '',
          name: _nameController.text.trim(),
          nim: _nimController.text.trim(),
          major: _majorController.text.trim(),
          fcmToken: existingData?.fcmToken,
          photoUrl: newPhotoUrl, // Simpan URL baru (atau lama)
        ),
      );

      // 4. Update Auth DisplayName
      if (userAuth.displayName != _nameController.text.trim()) {
        await userAuth.updateDisplayName(_nameController.text.trim());
        await userAuth.reload();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil disimpan!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menyimpan profil")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- BAGIAN FOTO PROFIL ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      // Logic Tampilan Gambar:
                      // 1. Jika ada foto baru (_pickedImage) -> Tampilkan itu.
                      // 2. Jika tidak ada foto baru, tapi ada foto lama di DB (_currentPhotoUrl) -> Tampilkan dari Network.
                      // 3. Jika tidak ada keduanya -> Tampilkan Icon Person.
                      image: _pickedImage != null
                          ? DecorationImage(
                              image: FileImage(_pickedImage!),
                              fit: BoxFit.cover,
                            )
                          : (_currentPhotoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_currentPhotoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null),
                    ),
                    child: (_pickedImage == null && _currentPhotoUrl == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage, // Klik tombol kamera -> Buka Galeri
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4A90E2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField(
              label: 'Nama Lengkap',
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'NIM',
              controller: _nimController,
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Jurusan',
              controller: _majorController,
              icon: Icons.school_outlined,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan Perubahan',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
            hintText: 'Masukkan $label',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
