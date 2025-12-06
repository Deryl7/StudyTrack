import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// HAPUS BARIS INI: import 'firebase_options.dart';
import 'services/database_service.dart';
import 'services/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // KITA GANTI BAGIAN INI:
  // Cukup panggil initializeApp tanpa parameter options.
  // Karena kamu sudah pasang google-services.json, Flutter akan otomatis
  // membaca konfigurasi dari file tersebut.
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Backend Test Area")),
        body: Center(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  // 1. Pura-pura Login (Pakai ID Sembarang dulu untuk tes)
                  String fakeUserId = "test_user_mahasiswa_1";

                  // 2. Inisialisasi Service
                  DatabaseService db = DatabaseService(uid: fakeUserId);
                  SeedData seeder = SeedData(dbService: db);

                  // 3. Eksekusi
                  await seeder.uploadDummyData();

                  // 4. Feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data Dummy Terkirim ke Firebase!"),
                    ),
                  );
                },
                child: const Text("UPLOAD DATA DUMMY"),
              );
            },
          ),
        ),
      ),
    );
  }
}
