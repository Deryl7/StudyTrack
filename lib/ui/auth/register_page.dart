import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  // Field State
  String name = '';
  String email = '';
  String password = '';
  String nim = '';
  String major = '';
  String error = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Akun Baru"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Mulai Perjalananmu 🚀",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lengkapi data dirimu untuk memulai.",
                style: GoogleFonts.inter(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Fields
              _buildTextField(
                label: "Nama Lengkap",
                icon: Icons.person_outline,
                onChanged: (val) => name = val,
              ),
              _buildTextField(
                label: "Email",
                icon: Icons.email_outlined,
                onChanged: (val) => email = val,
              ),
              _buildTextField(
                label: "NIM",
                icon: Icons.badge_outlined,
                onChanged: (val) => nim = val,
              ),
              _buildTextField(
                label: "Program Studi",
                icon: Icons.school_outlined,
                onChanged: (val) => major = val,
              ),
              _buildTextField(
                label: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
                onChanged: (val) => password = val,
              ),

              const SizedBox(height: 12),
              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);

                          // Panggil fungsi register dari AuthService
                          dynamic result = await _auth.registerWithEmail(
                            email: email,
                            password: password,
                            name: name,
                            nim: nim,
                            major: major,
                          );

                          if (result == null) {
                            setState(() {
                              error =
                                  'Gagal mendaftar. Cek koneksi atau email.';
                              isLoading = false;
                            });
                          } else {
                            // Jika sukses, Navigator pop untuk kembali ke AuthWrapper -> Home
                            if (mounted) Navigator.pop(context);
                          }
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Daftar Akun"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: isPassword,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: (val) => val!.isEmpty ? '$label tidak boleh kosong' : null,
        onChanged: onChanged,
      ),
    );
  }
}
