import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream: Ini "CCTV" yang memantau apakah user sedang login atau logout.
  // Temanmu yang integrasi akan sangat butuh ini untuk redirect halaman (Login vs Home).
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // 1. REGISTER (Daftar Akun Baru)
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String nim,
    required String major,
  }) async {
    try {
      // A. Buat Akun di Firebase Auth (Server Keamanan)
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // B. Jika sukses, buat dokumen profil di Firestore (Database Data)
        // Kita panggil DatabaseService yang sudah kamu buat
        DatabaseService dbService = DatabaseService(uid: user.uid);

        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          nim: nim,
          major: major,
          fcmToken: null, // Token akan diisi nanti saat login di HP
        );

        await dbService.updateUserData(newUser);
        return user;
      }
    } catch (e) {
      print("Error Register: $e");
      // Kamu bisa throw error di sini agar UI bisa menampilkan pesan error (misal: Email sudah dipakai)
      rethrow;
    }
    return null;
  }

  // 2. LOGIN
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Error Login: $e");
      rethrow;
    }
  }

  // 3. LOGOUT
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("Error Logout: $e");
    }
  }
}
