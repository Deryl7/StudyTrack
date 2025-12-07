import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isDone;
  final String courseId; // Link ke ID mata kuliah
  final String courseName; // Disimpan biar gampang query notifikasi
  final String ownerId; // ID User pemilik tugas
  final String type;
  final String? fileUrl; // Boleh null, karena tidak semua tugas ada filenya
  final String?
  fileName; // Opsional: Biar di UI tampil nama filenya (misal: "soal_mtk.pdf")

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isDone,
    required this.courseId,
    required this.courseName,
    required this.ownerId,
    this.type = 'Tugas',
    this.fileUrl,
    this.fileName,
  });

  factory TaskModel.fromMap(Map<String, dynamic> data, String documentId) {
    return TaskModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      // Konversi Timestamp Firestore ke DateTime Dart
      deadline: (data['deadline'] as Timestamp).toDate(),
      isDone: data['isDone'] ?? false,
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      ownerId: data['owner_id'] ?? '',
      type: data['type'] ?? 'Tugas',
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'isDone': isDone,
      'courseId': courseId,
      'courseName': courseName,
      'owner_id': ownerId,
      'type': type,
      'fileUrl': fileUrl,
      'fileName': fileName,
    };
  }
}
