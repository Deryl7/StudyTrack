import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Services & Models
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';

// Screens
import 'edit_profile_screen.dart';
import 'support_screen.dart';
import '../notifications/notification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) return const SizedBox();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: StreamBuilder<UserModel>(
            // Stream ini mendengarkan perubahan data user dari database
            stream: DatabaseService(uid: user.uid).userData,
            builder: (context, snapshot) {
              // 1. Loading State
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Ambil Data User
              final userData = snapshot.data!;

              // Siapkan data untuk ditampilkan
              final displayName = userData.name.isNotEmpty
                  ? userData.name
                  : "Mahasiswa";
              final displayNim = userData.nim.isNotEmpty ? userData.nim : "-";
              final displayMajor = userData.major.isNotEmpty
                  ? userData.major
                  : "-";
              final photoUrl = userData.photoUrl; // Ambil URL Foto

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // --- FOTO PROFIL (LOGIC FINAL) ---
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    // Jika ada URL foto -> Tampilkan Foto
                    // Jika tidak ada -> Tampilkan NULL (biar child Icon muncul)
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : null,
                    // Jika foto tidak ada -> Tampilkan Icon Orang
                    child: photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // --- NAMA & EMAIL ---
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email ?? "-",
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  // --- NIM & JURUSAN ---
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$displayNim • $displayMajor",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- MENU NAVIGASI ---
                  _buildProfileMenu(
                    icon: Icons.settings,
                    title: "Pengaturan Akun",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),

                  _buildProfileMenu(
                    icon: Icons.notifications,
                    title: "Notifikasi",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),

                  _buildProfileMenu(
                    icon: Icons.help_outline,
                    title: "Bantuan & Support",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SupportScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

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
                  const SizedBox(height: 20),

                  // TOMBOL RESET GOOGLE (Versi Lebih Cerewet)
                  TextButton(
                    onPressed: () async {
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      String message = "Berhasil Reset!"; // Pesan default

                      try {
                        // Cek dulu apakah sedang login
                        if (await googleSignIn.isSignedIn()) {
                          await googleSignIn.disconnect();
                        }
                        await googleSignIn.signOut();

                        message = "Google Disconnected. Siap Export ulang!";
                      } catch (e) {
                        // Tangkap errornya dan masukkan ke pesan
                        message = "Gagal Reset: $e";
                        print("ERROR RESET: $e");
                      }

                      // TAMPILKAN SNACKBAR (Apapun yang terjadi)
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: message.contains("Gagal")
                                ? Colors.red
                                : Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Reset Izin Google",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

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
