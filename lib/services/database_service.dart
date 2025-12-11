import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final String uid;

  // Constructor: Kita butuh UID user yang sedang login agar data tidak tertukar
  DatabaseService({required this.uid});

  // Reference ke Collection utama
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection('users');

  // ==============================================================================
  // 1. MANAJEMEN USER PROFILE
  // ==============================================================================

  // Fungsi untuk menyimpan/update data user saat pertama kali register atau login
  Future<void> updateUserData(UserModel user) async {
    return await userCollection
        .doc(uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // Fungsi update FCM Token untuk notifikasi
  Future<void> updateFcmToken(String token) async {
    return await userCollection.doc(uid).update({'fcm_token': token});
  }

  // ==============================================================================
  // 2. MANAJEMEN MATAKULIAH (COURSES)
  // ==============================================================================

  // Create Course
  Future<void> addCourse(CourseModel course) async {
    // Kita pakai .doc().set() agar bisa generate ID sendiri jika mau,
    // tapi pakai .add() lebih mudah untuk auto-ID.
    // Di sini kita pakai Sub-collection 'courses' di dalam user.
    await userCollection.doc(uid).collection('courses').add(course.toMap());
  }

  // Delete Course
  Future<void> deleteCourse(String courseId) async {
    await userCollection.doc(uid).collection('courses').doc(courseId).delete();
  }

  // READ Courses (Stream) - Agar UI update otomatis kalau ada perubahan
  Stream<List<CourseModel>> get courses {
    return userCollection
        .doc(uid)
        .collection('courses')
        .orderBy('day') // Urutkan berdasarkan hari (Senin=1)
        .snapshots()
        .map(_courseListFromSnapshot);
  }

  // Helper: Mengubah Snapshot Firestore menjadi List<CourseModel>
  List<CourseModel> _courseListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return CourseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // ==============================================================================
  // 3. MANAJEMEN TUGAS (TASKS)
  // ==============================================================================

  // Create Task
  Future<void> addTask(TaskModel task) async {
    // PENTING: Kita harus sertakan 'owner_id' agar Cloud Functions bisa menemukannya
    // walau tersimpan di sub-collection.
    await userCollection.doc(uid).collection('tasks').add({
      ...task.toMap(),
      'owner_id': uid, // Paksa isi owner_id dari UID service ini
    });
  }

  // Update Status Tugas (Mark as Done/Undone)
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await userCollection.doc(uid).collection('tasks').doc(taskId).update({
      'isDone': !currentStatus,
    });
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await userCollection.doc(uid).collection('tasks').doc(taskId).delete();
  }

  // READ Tasks (Stream) - Filter logic bisa dilakukan di UI atau di sini
  // Ini mengambil SEMUA tugas, nanti UI yang filter Pending/Done
  Stream<List<TaskModel>> get tasks {
    return userCollection
        .doc(uid)
        .collection('tasks')
        .orderBy('deadline') // Yang deadline dekat muncul duluan
        .snapshots()
        .map(_taskListFromSnapshot);
  }

  // Helper: Mengubah Snapshot Firestore menjadi List<TaskModel>
  List<TaskModel> _taskListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TaskModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // Ambil Data User (GET)
  Future<UserModel?> getUserData() async {
    try {
      DocumentSnapshot doc = await userCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error Get User Data: $e");
      return null;
    }
  }

  // Mengambil Data User secara Realtime (Otomatis Update)
  Stream<UserModel> get userData {
    return userCollection.doc(uid).snapshots().map((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  // Kirim Feedback
  Future<void> sendFeedback(String content) async {
    try {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'userId': uid,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        // Opsional: Bisa tambah info lain seperti versi aplikasi, tipe HP, dll
      });
    } catch (e) {
      print("Error sending feedback: $e");
      rethrow;
    }
  }
}
