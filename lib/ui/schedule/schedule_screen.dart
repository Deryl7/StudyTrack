import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/database_service.dart';
import '../../models/course_model.dart';
import '../../services/calendar_service.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final db = DatabaseService(uid: user!.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Kuliah"), centerTitle: false),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCourseDialog(context, db),
      ),
      body: StreamBuilder<List<CourseModel>>(
        stream: db.courses,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const Center(
              child: Text("Belum ada jadwal. Tambah sekarang!"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    color: Color(
                      int.parse(course.color.replaceAll('#', '0xff')),
                    ),
                  ),
                  title: Text(
                    course.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${_dayToString(course.day)} • ${course.startTime} - ${course.endTime}\n${course.lecturer}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOMBOL EXPORT (UPDATED: Icon & Logic disamakan)
                      IconButton(
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.blue,
                        ), // Icon disamakan
                        tooltip: "Export ke Google Calendar",
                        onPressed: () async {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Menghubungkan ke Google Calendar...",
                              ),
                            ),
                          );

                          // 1. Logic Cari Tanggal Jadwal Terdekat
                          final now = DateTime.now();
                          final startParts = course.startTime.split(':');
                          final endParts = course.endTime.split(':');

                          final startH = int.parse(startParts[0]);
                          final startM = int.parse(startParts[1]);
                          final endH = int.parse(endParts[0]);
                          final endM = int.parse(endParts[1]);

                          int daysDiff = course.day - now.weekday;
                          if (daysDiff < 0) {
                            daysDiff += 7;
                          } else if (daysDiff == 0) {
                            if (startH < now.hour ||
                                (startH == now.hour && startM < now.minute)) {
                              daysDiff += 7;
                            }
                          }

                          final targetDate = now.add(Duration(days: daysDiff));
                          final startDateTime = DateTime(
                            targetDate.year,
                            targetDate.month,
                            targetDate.day,
                            startH,
                            startM,
                          );
                          final endDateTime = DateTime(
                            targetDate.year,
                            targetDate.month,
                            targetDate.day,
                            endH,
                            endM,
                          );

                          // 2. Panggil Service (Sama seperti di Tugas)
                          String
                          resultMessage = await CalendarService().insertEvent(
                            title: "Kuliah: ${course.name}",
                            description:
                                "Ruang: ${course.room}\nDosen: ${course.lecturer}",
                            startTime: startDateTime,
                            endTime: endDateTime,
                          );

                          // 3. Tampilkan Pesan Error/Sukses Asli
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resultMessage),
                                backgroundColor:
                                    resultMessage.contains("SUKSES")
                                    ? Colors.green
                                    : Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                      ),

                      // TOMBOL DELETE
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => db.deleteCourse(course.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _dayToString(int day) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[(day - 1) % 7];
  }

  // DIALOG TAMBAH JADWAL
  void _showAddCourseDialog(BuildContext context, DatabaseService db) {
    final nameController = TextEditingController();
    final lecturerController = TextEditingController();
    final roomController = TextEditingController();
    final startController = TextEditingController(text: "08:00");
    final endController = TextEditingController(text: "10:00");
    int selectedDay = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Tambah Mata Kuliah",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Matkul"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lecturerController,
                decoration: const InputDecoration(labelText: "Dosen"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(labelText: "Ruangan"),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(
                        labelText: "Jam Mulai (HH:MM)",
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(
                        labelText: "Jam Selesai",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: selectedDay,
                items: List.generate(
                  7,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      [
                        "Senin",
                        "Selasa",
                        "Rabu",
                        "Kamis",
                        "Jumat",
                        "Sabtu",
                        "Minggu",
                      ][index],
                    ),
                  ),
                ),
                onChanged: (val) => selectedDay = val!,
                decoration: const InputDecoration(labelText: "Hari"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newCourse = CourseModel(
                  id: '', // Firestore auto-id nanti
                  name: nameController.text,
                  lecturer: lecturerController.text,
                  day: selectedDay,
                  startTime: startController.text,
                  endTime: endController.text,
                  room: roomController.text,
                  color: "#4A90E2", // Default Blue
                );
                await db.addCourse(newCourse);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
