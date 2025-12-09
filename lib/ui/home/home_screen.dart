import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Backend Imports
import '../../services/database_service.dart';
import '../../models/task_model.dart';
import '../../models/course_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil User UID dari Provider
    final user = Provider.of<User?>(context);
    if (user == null) return const SizedBox(); // Safety check

    final db = DatabaseService(uid: user.uid);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              _buildHeader(user),
              const SizedBox(height: 24),

              // SECTION 1: STATISTIK TUGAS (STREAM)
              StreamBuilder<List<TaskModel>>(
                stream: db.tasks,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();

                  final tasks = snapshot.data!;
                  final pendingTasks = tasks.where((t) => !t.isDone).length;
                  final completedToday = tasks
                      .where((t) => t.isDone)
                      .length; // Simplifikasi logic

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Sisa Tugas",
                          "$pendingTasks",
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          "Selesai",
                          "$completedToday",
                          Colors.green,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // SECTION 2: JADWAL HARI INI (STREAM)
              Text(
                "Jadwal Hari Ini",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<List<CourseModel>>(
                stream: db.courses,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filter Jadwal Hari Ini (1=Senin, dst)
                  // DateTime.weekday: 1=Senin, 7=Minggu. Cocok dengan model kita.
                  final today = DateTime.now().weekday;
                  final todayCourses = snapshot.data!
                      .where((c) => c.day == today)
                      .toList();

                  if (todayCourses.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayCourses.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(todayCourses[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${user.displayName ?? 'Mahasiswa'}! 👋",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
          ],
        ),
        CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.notifications_outlined, color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Color(int.parse(course.color.replaceAll('#', '0xff'))),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.startTime,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              Text(
                course.endTime,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                Text(
                  "${course.room} • ${course.lecturer}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.weekend_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            "Tidak ada jadwal kuliah hari ini.",
            style: GoogleFonts.inter(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
