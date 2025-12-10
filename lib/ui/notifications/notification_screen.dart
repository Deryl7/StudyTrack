import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/task_model.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final db = DatabaseService(uid: user!.uid);

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi"), centerTitle: true),
      body: StreamBuilder<List<TaskModel>>(
        stream: db.tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!;
          final now = DateTime.now();

          // LOGIKA FILTER NOTIFIKASI
          // 1. Tugas Terlewat (Overdue)
          final overdueTasks = tasks
              .where((t) => !t.isDone && t.deadline.isBefore(now))
              .toList();

          // 2. Tugas Mepet (H-2 atau kurang)
          final upcomingTasks = tasks
              .where(
                (t) =>
                    !t.isDone &&
                    t.deadline.isAfter(now) &&
                    t.deadline.difference(now).inDays <= 2,
              )
              .toList();

          if (overdueTasks.isEmpty && upcomingTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada notifikasi baru",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (overdueTasks.isNotEmpty) ...[
                Text(
                  "Perlu Perhatian! 🚨",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                ...overdueTasks.map((t) => _buildNotifCard(t, isOverdue: true)),
                const SizedBox(height: 24),
              ],

              if (upcomingTasks.isNotEmpty) ...[
                Text(
                  "Segera Kerjakan ⏰",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                ...upcomingTasks.map(
                  (t) => _buildNotifCard(t, isOverdue: false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotifCard(TaskModel task, {required bool isOverdue}) {
    return Card(
      color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: isOverdue ? Colors.red : Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isOverdue ? Icons.warning_amber_rounded : Icons.access_time_filled,
          color: isOverdue ? Colors.red : Colors.orange,
        ),
        title: Text(
          task.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isOverdue
              ? "Tugas ini sudah melewati deadline!"
              : "Deadline: ${DateFormat('d MMM HH:mm').format(task.deadline)}",
          style: GoogleFonts.inter(fontSize: 12),
        ),
      ),
    );
  }
}
