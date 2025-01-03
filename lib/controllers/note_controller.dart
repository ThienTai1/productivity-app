import 'package:get/get.dart';
import '../models/note.dart';
import '../services/database_service.dart';

class NoteController extends GetxController {
  final _db = DatabaseService.instance;
  final notes = <Note>[].obs;

  Future<void> loadNotes(int userId) async {
    final notesList = await _db.getNotes(userId);
    notes.assignAll(notesList);
  }

  Future<void> addNote(Note note) async {
    final newNote = await _db.createNote(note);
    notes.insert(0, newNote);
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(note);
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
    }
  }

  Future<void> deleteNote(int id) async {
    await _db.deleteNote(id);
    notes.removeWhere((note) => note.id == id);
  }
}