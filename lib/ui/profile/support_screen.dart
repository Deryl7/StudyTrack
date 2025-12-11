import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Import ini
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/database_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _feedbackController = TextEditingController();
  bool _isSending = false;

  // Fungsi untuk membuka Email/Telepon
  Future<void> _launchContact(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback jika canLaunchUrl return false (kadang terjadi di simulator)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka aplikasi kontak")),
        );
      }
    }
  }

  // Fungsi Kirim Feedback ke Firestore
  Future<void> _sendFeedback() async {
    if (_feedbackController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final user = Provider.of<User?>(context, listen: false);
      if (user != null) {
        await DatabaseService(
          uid: user.uid,
        ).sendFeedback(_feedbackController.text.trim());

        if (mounted) {
          _feedbackController.clear(); // Kosongkan input
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Masukan Anda berhasil dikirim!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal mengirim masukan")));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bantuan & Support",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Kontak
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Butuh Bantuan Mendesak?",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // KONTAK EMAIL (Bisa Diklik)
                  _buildContactRow(
                    icon: Icons.email,
                    text: "support@studytrack.id",
                    onTap: () => _launchContact(
                      Uri.parse(
                        "mailto:deryltammu7@gmail.com?subject=Bantuan StudyTrack",
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // KONTAK TELEPON (Bisa Diklik)
                  _buildContactRow(
                    icon: Icons.phone,
                    text: "+62 821-8170-6709",
                    onTap: () =>
                        _launchContact(Uri.parse("tel:+6282181706709")),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FAQ
            Text(
              "Pertanyaan Umum (FAQ)",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const ExpansionTile(
              title: Text("Bagaimana cara menambah jadwal?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Pergi ke menu Jadwal, lalu tekan tombol (+) di pojok kanan bawah.",
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text("Apakah data saya aman?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Ya, data Anda tersimpan aman di server Firebase Google.",
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text("Bagaimana cara export ke Kalender?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Klik ikon kalender biru pada kartu Tugas atau Jadwal. Pastikan Anda memberikan izin akses akun Google.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Send Feedback Form
            Text(
              "Kirim Masukan",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tulis saran atau keluhan Anda...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSending ? null : _sendFeedback,
                child: _isSending
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Kirim Feedback",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget baris kontak yang bisa diklik
  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration:
                      TextDecoration.underline, // Visual cue kalau bisa diklik
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
