Tentu, ini adalah draf **README.md** yang profesional dan lengkap untuk proyek **StudyTrack**.

Isi file ini mencakup deskripsi proyek, fitur unggulan, teknologi yang digunakan, cara instalasi, dan kredit anggota kelompok. Ini akan sangat berguna untuk dokumentasi di GitHub dan penilaian dosen.

Silakan buat file baru bernama `README.md` di root folder proyek kamu, lalu copy-paste kode di bawah ini:

# 🎓 StudyTrack - Personal Academic Assistant

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Backend-orange?logo=firebase)
![Dart](https://img.shields.io/badge/Dart-3.0-blue?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-green?logo=android)

**StudyTrack** adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk membantu mahasiswa mengelola kehidupan akademik mereka. Aplikasi ini mengintegrasikan jadwal kuliah, manajemen tugas, dan notifikasi otomatis dalam satu platform yang mudah digunakan.

---

## ✨ Fitur Unggulan

### 📅 Manajemen Akademik
* **Jadwal Kuliah:** Atur jadwal kuliah mingguan lengkap dengan info ruang dan dosen.
* **Manajemen Tugas:** Catat tugas, deadline, dan lampirkan file (PDF/Doc) terkait tugas tersebut.
* **Filter Cerdas:** Lihat tugas berdasarkan status (Selesai/Belum) atau kategori mata kuliah.

### 🤖 Otomatisasi & Notifikasi
* **Smart Reminder:** Sistem notifikasi otomatis (Cloud Functions) yang mengingatkan deadline tugas pada **H-3** dan **H-1**.
* **Realtime Update:** Data profil dan status tugas tersinkronisasi secara realtime di semua perangkat.

### 🔗 Integrasi Google
* **Google Calendar Export:** Ekspor jadwal kuliah dan deadline tugas langsung ke Google Calendar pribadi Anda dengan satu klik.
* **Secure Auth:** Login dan Register aman menggunakan Firebase Authentication.

### 👤 Personalisasi
* **Profil Pengguna:** Edit nama, NIM, jurusan, dan foto profil.
* **Bantuan & Feedback:** Fitur in-app untuk mengirim masukan atau menghubungi support.

---

## 🛠️ Teknologi yang Digunakan

* **Frontend:** Flutter (Dart)
* **Backend:** Firebase (Serverless)
    * **Authentication:** Manajemen user (Email/Password).
    * **Cloud Firestore:** Database NoSQL realtime.
    * **Cloud Storage:** Penyimpanan file lampiran tugas dan foto profil.
    * **Cloud Functions:** Backend logic untuk scheduler notifikasi (Node.js).
* **Integrasi:** Google Calendar API, Firebase Cloud Messaging (FCM).
* **State Management:** Provider.

---

## 📸 Screenshots

| Dashboard | Jadwal Kuliah | Detail Tugas | Profil User |
|:---:|:---:|:---:|:---:|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Jadwal](assets/screenshots/schedule.png) | ![Tugas](assets/screenshots/task.png) | ![Profil](assets/screenshots/profile.png) |

---

## 🚀 Cara Menjalankan Project (Installation)

Ikuti langkah-langkah ini untuk menjalankan project di lokal:

### Prasyarat
1.  Flutter SDK terinstall.
2.  Android Studio / VS Code.
3.  Perangkat Android (Fisik atau Emulator).

### Langkah Instalasi
1.  **Clone Repository**
    ```bash
    git clone [https://github.com/username-kalian/study_track.git](https://github.com/username-kalian/study_track.git)
    cd study_track
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Firebase**
    * Pastikan file `google-services.json` sudah ada di folder `android/app/`.
    * *(Jika belum ada, minta file ini kepada Tim Backend)*.

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

---

## 📂 Struktur Folder

```text
lib/
├── models/          # Data Models (User, Task, Course)
├── services/        # Logic (Auth, Database, Calendar, Storage)
├── ui/              # Tampilan Antarmuka
│   ├── auth/        # Halaman Login & Register
│   ├── home/        # Dashboard
│   ├── schedule/    # Halaman Jadwal
│   ├── tasks/       # Halaman Tugas
│   └── profile/     # Halaman Profil & Settings
└── main.dart        # Entry Point
````

-----

## 👥 Tim Pengembang

Project ini dibuat untuk memenuhi Tugas Final Project Pemrograman Mobile oleh:

1.  **[Deryl Dionedith Tammu]** - *Backend Engineer & Data Layer* (Firebase, API, Cloud Functions)
2.  **[Irfan Tanzilur Rahman]** - *UI/UX Designer* (Layouting, Screen Design, Assets)
3.  **[Muhamad Fauzan Rusda]** - *Integration & Logic* (State Management, Wiring Backend-Frontend)

-----

## 📄 Lisensi

Copyright © 2025 StudyTrack Team. All rights reserved.
