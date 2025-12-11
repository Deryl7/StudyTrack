import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';

// Screens
import 'home/home_screen.dart';
import 'schedule/schedule_screen.dart';

import 'tasks/task_screen.dart';
import 'profile/profile_screen.dart';

// Placeholder untuk Tahap 3
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text("Halaman $title (Coming Soon)"));
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Daftar Halaman
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0: Dashboard
    const ScheduleScreen(), // Index 1: Jadwal
    const TaskScreen(), // Index 2: Tugas (BARU)
    const ProfileScreen(), // Index 3: Profil (BARU)
  ];

  @override
  void initState() {
    super.initState();
    // Panggil fungsi setup notifikasi begitu Dashboard dibuka
    _setupNotifications();
  }

  void _setupNotifications() async {
    print("--- MULAI SETUP NOTIFIKASI ---");

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Minta Izin (Pop-up Allow/Block)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Status Izin: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      try {
        // 2. Ambil Token
        String? token = await messaging.getToken();
        print("Token didapat: $token");

        // 3. Kirim ke Database
        if (token != null && mounted) {
          // Ambil user yang sedang login dari Provider
          final user = Provider.of<User?>(context, listen: false);

          if (user != null) {
            await DatabaseService(uid: user.uid).updateFcmToken(token);
            print(
              "SUKSES! Token tersimpan di Database untuk user: ${user.email}",
            );
          } else {
            print("GAGAL: User null (Belum terdeteksi login).");
          }
        }
      } catch (e) {
        print("ERROR: Gagal ambil token - $e");
      }
    } else {
      print('Izin notifikasi ditolak user.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt_rounded),
              label: 'Tugas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
