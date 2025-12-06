import 'package:uuid/uuid.dart'; // Kita butuh ini untuk generate ID unik
import '../models/course_model.dart';
import '../models/task_model.dart';
import 'database_service.dart';

class SeedData {
  final DatabaseService dbService;

  // Butuh package uuid: flutter pub add uuid
  final Uuid _uuid = const Uuid();

  SeedData({required this.dbService});

  Future<void> uploadDummyData() async {
    print("Mulai mengisi data dummy...");

    // 1. DATA JADWAL KULIAH [cite: 14]
    // Kita simpan ID-nya di variabel agar bisa dipakai untuk link tugas
    final String courseId1 = _uuid.v4();
    final String courseId2 = _uuid.v4();

    final course1 = CourseModel(
      id: courseId1, // ID kita generate sendiri biar gampang
      name: "Pemrograman Mobile",
      lecturer: "Pak Dosen Flutter",
      day: 1, // Senin
      startTime: "08:00",
      endTime: "10:30",
      room: "Lab Komputer 1",
      color: "0xFFE57373", // Warna Merah Muda
    );

    final course2 = CourseModel(
      id: courseId2,
      name: "Statistika & Probabilitas",
      lecturer: "Bu Matematika",
      day: 3, // Rabu
      startTime: "13:00",
      endTime: "14:40",
      room: "R. Teori 305",
      color: "0xFF64B5F6", // Warna Biru Muda
    );

    // Upload Course
    // Perhatikan: Kita modifikasi sedikit addCourse di DatabaseService nanti
    // agar mau menerima custom ID, atau kita biarkan Firestore generate ID (tapi di sini kita pakai trik manual add).
    // Untuk seed data, kita pakai fungsi khusus di bawah.
    await _addCourseWithId(course1);
    await _addCourseWithId(course2);

    // 2. DATA TUGAS (Ada yg H-3, H-1, dan Selesai) [cite: 17, 23]
    final now = DateTime.now();

    final task1 = TaskModel(
      id: _uuid.v4(),
      title: "Final Project Backend",
      description: "Implementasi Firebase & Cloud Functions",
      deadline: now.add(const Duration(days: 3)), // Deadline H-3 (Ngetes Notif)
      isDone: false,
      courseId: courseId1, // Link ke Pemrograman Mobile
      courseName: course1.name,
      ownerId: dbService.uid,
    );

    final task2 = TaskModel(
      id: _uuid.v4(),
      title: "Latihan Soal Bab 1",
      description: "Halaman 10 - 15 buku paket",
      deadline: now.add(const Duration(days: 1)), // Deadline Besok (H-1)
      isDone: false,
      courseId: courseId2, // Link ke Statistika
      courseName: course2.name,
      ownerId: dbService.uid,
    );

    final task3 = TaskModel(
      id: _uuid.v4(),
      title: "Install Flutter SDK",
      description: "Setup lingkungan kerja",
      deadline: now.subtract(const Duration(days: 2)), // Sudah lewat
      isDone: true, // Sudah selesai
      courseId: courseId1,
      courseName: course1.name,
      ownerId: dbService.uid,
    );

    // Upload Tasks
    await dbService.addTask(task1);
    await dbService.addTask(task2);
    await dbService.addTask(task3);

    print("Data dummy berhasil ditambahkan! Cek Firestore.");
  }

  // Fungsi bantuan khusus Seed Data untuk memaksa ID tertentu (opsional)
  Future<void> _addCourseWithId(CourseModel course) async {
    // Mengakses collection user -> subcollection courses
    // Menggunakan .doc(course.id).set(...) agar ID sesuai keinginan kita
    await dbService.userCollection
        .doc(dbService.uid)
        .collection('courses')
        .doc(course.id)
        .set(course.toMap());
  }
}
