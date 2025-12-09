import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import '../../services/database_service.dart';
import '../../services/storage_services.dart';
import '../../models/task_model.dart';
import '../../models/course_model.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  bool _showOnlyPending = false; // Filter status tugas

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final db = DatabaseService(uid: user!.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Tugas"),
        actions: [
          // Filter Button
          IconButton(
            icon: Icon(
              _showOnlyPending ? Icons.filter_alt : Icons.filter_alt_off,
            ),
            tooltip: "Filter Belum Selesai",
            onPressed: () =>
                setState(() => _showOnlyPending = !_showOnlyPending),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context, db),
        label: const Text("Tugas Baru"),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<List<TaskModel>>(
        stream: db.tasks,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var tasks = snapshot.data!;

          // Logic Filter
          if (_showOnlyPending) {
            tasks = tasks.where((t) => !t.isDone).toList();
          }

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada tugas. Santai dulu! ☕",
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task, db);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task, DatabaseService db) {
    final isOverdue = task.deadline.isBefore(DateTime.now()) && !task.isDone;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isDone,
          activeColor: Colors.green,
          shape: const CircleBorder(),
          onChanged: (val) => db.toggleTaskStatus(task.id, task.isDone),
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              task.courseName,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Text(
              "Deadline: ${DateFormat('d MMM HH:mm').format(task.deadline)}",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isOverdue ? Colors.red : Colors.grey,
              ),
            ),
            if (task.fileName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    task.fileName!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => db.deleteTask(task.id),
        ),
      ),
    );
  }

  // --- FORM TAMBAH TUGAS (MODAL) ---
  void _showAddTaskSheet(BuildContext context, DatabaseService db) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTaskForm(),
      ),
    );
  }
}

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});
  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedCourseId;
  String _selectedCourseName = "";
  File? _pickedFile; // File yang dipilih
  String? _fileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final db = DatabaseService(uid: user!.uid);
    final storage = StorageService();

    return Container(
      padding: const EdgeInsets.all(24),
      height: 600, // Fixed height agar cukup
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tambah Tugas Baru",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Judul Tugas"),
          ),
          const SizedBox(height: 12),

          // Dropdown Mata Kuliah (Ambil dari Firestore)
          StreamBuilder<List<CourseModel>>(
            stream: db.courses,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return DropdownButtonFormField<String>(
                value:
                    _selectedCourseId, // Menggunakan value untuk kontrol state
                hint: const Text("Pilih Mata Kuliah"),
                items: snapshot.data!.map((course) {
                  return DropdownMenuItem(
                    value: course.id,
                    child: Text(course.name),
                    onTap: () => _selectedCourseName = course.name,
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCourseId = val),
              );
            },
          ),

          const SizedBox(height: 12),

          // Date Picker sederhana
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Deadline"),
            trailing: Text(DateFormat('EEE, d MMM yyyy').format(_selectedDate)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),

          const SizedBox(height: 12),

          // UPLOAD FILE AREA
          GestureDetector(
            onTap: _pickFile,
            child: DottedBorder(
              color: Colors.grey,
              strokeWidth: 1,
              dashPattern: const [6, 3],
              borderType: BorderType.RRect,
              radius: const Radius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: _pickedFile == null
                    ? Column(
                        children: const [
                          Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                          Text("Tap untuk upload lampiran (.pdf)"),
                        ],
                      )
                    : Row(
                        children: [
                          const Icon(Icons.description, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_fileName!)),
                          const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
              ),
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading
                  ? null
                  : () async {
                      if (_titleController.text.isEmpty ||
                          _selectedCourseId == null) {
                        return;
                      }

                      setState(() => _isUploading = true);

                      String? downloadUrl;

                      // 1. Upload File jika ada
                      if (_pickedFile != null) {
                        downloadUrl = await storage.uploadTaskFile(
                          _pickedFile!,
                          _fileName!,
                        );
                      }

                      // 2. Simpan Data Tugas
                      final newTask = TaskModel(
                        id: '',
                        title: _titleController.text,
                        description: _descController.text,
                        deadline: _selectedDate,
                        isDone: false,
                        courseId: _selectedCourseId!,
                        courseName: _selectedCourseName,
                        ownerId: user.uid,
                        fileUrl: downloadUrl,
                        fileName: _fileName,
                      );

                      await db.addTask(newTask);

                      // --- PERBAIKAN DI SINI ---
                      // Menggunakan context.mounted untuk memastikan widget masih aktif
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
              child: _isUploading
                  ? const Text("Mengupload...")
                  : const Text("Simpan Tugas"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }
}
