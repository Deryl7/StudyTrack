import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

// --- IMPORT NAVIGASI (Sesuai Struktur Folder Anda) ---
import 'edit_profile_screen.dart'; // Satu folder dengan profile_screen.dart
import 'support_screen.dart'; // Satu folder dengan profile_screen.dart
import '../notifications/notification_screen.dart'; // Mundur satu folder, masuk notifications

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // --- FOTO PROFIL ---
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // --- DATA USER ---
              Text(
                user?.displayName ?? "Mahasiswa",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? "-",
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // --- MENU NAVIGASI ---

              // 1. TOMBOL PENGATURAN AKUN
              _buildProfileMenu(
                icon: Icons.settings,
                title: "Pengaturan Akun",
                onTap: () {
                  // Navigasi ke EditProfileScreen dengan mengirim data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        // Mengirim data user saat ini ke form edit
                        currentName: user?.displayName ?? "",
                        currentNim:
                            "2021110045", // Ganti dengan data real jika sudah ada di database
                        currentMajor:
                            "Computer Science", // Ganti dengan data real jika sudah ada
                        currentImage: null,
                      ),
                    ),
                  );
                },
              ),

              // 2. TOMBOL NOTIFIKASI
              _buildProfileMenu(
                icon: Icons.notifications,
                title: "Notifikasi",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Hapus 'const' jika NotificationScreen punya konten dinamis
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),

              // 3. TOMBOL BANTUAN & SUPPORT
              _buildProfileMenu(
                icon: Icons.help_outline,
                title: "Bantuan & Support",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Pastikan menggunakan SupportScreen() yang benar
                      builder: (context) => const SupportScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk membuat Menu
  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}
