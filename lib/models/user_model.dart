class UserModel {
  final String uid;
  final String email;
  final String name;
  final String nim;
  final String major; // Program Studi
  final String? fcmToken; // Untuk notifikasi

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.nim,
    required this.major,
    this.fcmToken,
  });

  // Mengubah data dari Firestore ke objek Dart
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      nim: data['nim'] ?? '',
      major: data['major'] ?? '',
      fcmToken: data['fcm_token'],
    );
  }

  // Mengubah objek Dart ke JSON untuk dikirim ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'nim': nim,
      'major': major,
      'fcm_token': fcmToken,
    };
  }
}
