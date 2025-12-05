class CourseModel {
  final String id;
  final String name;
  final String lecturer; // Dosen
  final int day; // 1 = Senin, 7 = Minggu
  final String startTime; // Format "08:00"
  final String endTime; // Format "10:30"
  final String room;
  final String color; // Hex color code (misal: "#FF0000")

  CourseModel({
    required this.id,
    required this.name,
    required this.lecturer,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.color,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CourseModel(
      id: documentId,
      name: data['name'] ?? '',
      lecturer: data['lecturer'] ?? '',
      day: data['day'] ?? 1,
      startTime: data['startTime'] ?? '00:00',
      endTime: data['endTime'] ?? '00:00',
      room: data['room'] ?? '',
      color: data['color'] ?? '#000000',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lecturer': lecturer,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'color': color,
    };
  }
}
