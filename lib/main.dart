import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Services
import 'services/auth_service.dart';

// Import UI
import 'ui/auth/login_page.dart';
import 'ui/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. MULTIPROVIDER: Ini adalah "Jantung"-nya.
    // Dia memompa data 'User' (login/logout) ke seluruh halaman di bawahnya.
    return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: AuthService().user,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'StudyTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF4A90E2),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
        ),
        // 2. AUTH WRAPPER: Penjaga Pintu
        // Dia yang memutuskan user masuk ke Login atau langsung Dashboard
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user dari Provider di atas
    final user = Provider.of<User?>(context);

    // LOGIC:
    // Kalau user null (belum login) -> Tampilkan Login Page
    // Kalau user ada data (sudah login) -> Tampilkan Main Layout (Dashboard)
    if (user == null) {
      return const LoginPage();
    } else {
      return const MainLayout();
    }
  }
}
