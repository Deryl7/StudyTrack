import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bantuan & Support",
          style: GoogleFonts.poppins(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    // PERBAIKAN DI SINI: Gunakan withOpacity agar tidak error
                    color: Colors.black.withOpacity(0.1),
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
                  _buildContactRow(Icons.email, "support@studytrack.id"),
                  const SizedBox(height: 8),
                  _buildContactRow(Icons.phone, "+62 812-3456-7890"),
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Terima kasih atas masukan Anda!"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text("Kirim Feedback"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget baris kontak
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        // PERBAIKAN: Gunakan withOpacity
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            text,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
