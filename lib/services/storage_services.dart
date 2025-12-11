import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Fungsi 1: Upload File
  // Mengembalikan URL download (String) jika sukses, atau null jika gagal
  Future<String?> uploadTaskFile(File file, String fileName) async {
    try {
      // 1. Buat nama file unik agar tidak menimpa file orang lain
      // Contoh: 1708892991000_tugas_mtk.pdf
      String uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      // 2. Tentukan lokasi folder: task_files/nama_file
      Reference ref = _storage.ref().child('task_files/$uniqueName');

      // 3. Mulai proses upload
      UploadTask uploadTask = ref.putFile(file);

      // (Opsional) Monitor progress upload bisa dilakukan di sini lewat uploadTask.snapshotEvents

      // 4. Tunggu sampai selesai
      TaskSnapshot snapshot = await uploadTask;

      // 5. Ambil Link Download (URL)
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print("Error Upload File: $e");
      return null;
    }
  }

  // Fungsi 2: Hapus File (Dipanggil jika user menghapus tugas)
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Firebase Storage pintar, dia bisa cari lokasi file cuma dari URL-nya
      await _storage.refFromURL(fileUrl).delete();
    } catch (e) {
      print("Error Delete File: $e");
    }
  }

  // FUNGSI BARU: Upload Foto Profil
  Future<String?> uploadProfileImage(File file, String uid) async {
    try {
      // Simpan di folder 'user_profiles', nama filenya adalah UID user.
      // Jadi kalau user upload lagi, foto lama otomatis tertimpa.
      Reference ref = _storage.ref().child('user_profiles/$uid.jpg');

      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error Upload Profile: $e");
      return null;
    }
  }
}
