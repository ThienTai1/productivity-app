import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:flutter_notes_app/models/note.dart';
import 'package:flutter_notes_app/screens/notes/note_detail.dart';
import 'package:flutter_notes_app/widgets/app_drawer.dart';
import 'package:get/get.dart';
import '../../controllers/note_controller.dart';

class NotesScreen extends StatefulWidget {
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _noteController = Get.find<NoteController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserNotes();
    });
  }

  void _loadUserNotes() {
    if (_authController.currentUser.value?.id != null) {
      _noteController.loadNotes(_authController.currentUser.value!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout),
        //     onPressed: () {
        //       _authController.logout();
        //       _noteController.notes.clear();
        //       Get.offAllNamed('/login');
        //     },
        //   ),
        // ],
      ),
      drawer: AppDrawer(),
      body: Obx(() => GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _noteController.notes.length,
        itemBuilder: (context, index) {
          final note = _noteController.notes[index];
          return _buildNoteCard(note);
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () async {
        final needRefresh = await Get.to(() => NoteDetailScreen(note: note));
        if (needRefresh == true) {
          _loadUserNotes();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              width: double.infinity,
              child: Text(
                note.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  note.content,
                  style: TextStyle(fontSize: 14),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                _formatDate(note.createdAt),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

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
                  final newNote = Note(
                    userId: _authController.currentUser.value!.id!,
                    title: titleController.text,
                    content: contentController.text,
                  );
                  await _noteController.addNote(newNote);
                  Get.back();
                  _loadUserNotes();
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}