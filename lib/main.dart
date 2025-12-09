import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Services
import 'services/auth_service.dart';

// UI Pages
import 'ui/auth/login_page.dart';
import 'ui/main_layout.dart'; // <--- Ini yang benar untuk main.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        title: 'StudyTrack',
        debugShowCheckedModeBanner: false,
        theme: _buildThemeData(),
        home: const MainLayout(),
      ),
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: const Color(0xFF4A90E2),
      scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: const Color(0xFF4A90E2),
        secondary: const Color(0xFFFFB800),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFF2D3436),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D3436)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const LoginPage();
    } else {
      return const MainLayout();
    }
  }
}
