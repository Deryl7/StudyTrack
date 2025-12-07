
# Panduan Integrasi Backend StudyTrack

Status Backend: **READY (100%)** 🚀

Author: Deryl Dionedith Tammu

Berikut adalah panduan cara menggunakan service backend untuk Tim UI & Integrasi.

## 1. Setup Awal (Wajib)
Pastikan file `google-services.json` sudah ada di folder `android/app`. Jika belum, minta ke saya.

## 2. Authentication (AuthService)
Gunakan `AuthService` untuk login/register.

```dart
// Cara Register
await AuthService().registerWithEmail(
  email: emailController.text,
  password: passController.text,
  name: nameController.text,
  nim: nimController.text,
  major: majorController.text
);

// Cara Login
await AuthService().loginWithEmail(email, password);

// Cek Status Login (Stream)
// Gunakan ini di main.dart untuk redirect halaman (Login vs Home)
StreamBuilder<User?>(
  stream: AuthService().user,
  builder: (context, snapshot) {
    if (snapshot.hasData) return HomePage();
    return LoginPage();
  }
)
```

## 3. Data Tugas (DatabaseService)

Gunakan `DatabaseService` untuk CRUD tugas. Jangan lupa `uid` user yang sedang login.

```dart
final db = DatabaseService(uid: user.uid);

// A. Ambil Data (Realtime Stream)
StreamBuilder<List<TaskModel>>(
  stream: db.tasks, // Otomatis update jika database berubah
  builder: (context, snapshot) {
    // Render List di sini
  }
)

// B. Tambah Tugas (PENTING: Perhatikan Field Type & File)
db.addTask(TaskModel(
  // ... field wajib lain ...
  type: 'Tugas', // Isi 'Tugas' atau 'Ujian' (Mempengaruhi Notifikasi H-3)
  fileUrl: uploadedUrl, // Isi URL dari StorageService jika ada file
));
```

## 4. Upload File (StorageService)

Jika user ingin upload file tugas/soal.

```dart
// 1. Ambil file dari HP (pakai file_picker)
File? file = ...;

// 2. Upload ke Firebase
String? url = await StorageService().uploadTaskFile(file, "nama_file.pdf");

// 3. Masukkan 'url' tersebut ke dalam addTask() di atas.
```

## 5. Fitur Lain

  * **Google Calendar:** Akun Google Test sudah didaftarkan. Gunakan package `googleapis` untuk insert event.
  * **Data Dummy:** Panggil `SeedData(dbService: db).uploadDummyData()` untuk isi data otomatis saat testing UI.

<!-- end list -->