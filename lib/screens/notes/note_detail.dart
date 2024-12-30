import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/note_controller.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:get/get.dart';


class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final NoteController _noteController = Get.find();

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Note Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _noteController.deleteNote(note.id!);
              Get.back(result: true); // Trả về true để báo hiệu cần refresh
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Created at: ${_formatDate(note.createdAt)}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                note.content,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    Get.dialog(
      Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final updatedNote = Note(
                    id: note.id,
                    userId: note.userId,
                    title: titleController.text,
                    content: contentController.text,
                    createdAt: note.createdAt,
                  );
                  await _noteController.updateNote(updatedNote);
                  Get.back(); // Đóng dialog
                  Get.back(result: true); // Quay về màn hình notes với kết quả refresh
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}