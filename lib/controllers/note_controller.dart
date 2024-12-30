import 'package:get/get.dart';
import '../models/note.dart';
import '../services/database_service.dart';

// class NoteController extends GetxController {
//   var notes = <Note>[].obs; // Danh sách ghi chú
//   final DatabaseService _dbService = DatabaseService();

//   // Phương thức khởi tạo
//   @override
//   void onInit() {
//     super.onInit();
//   }

//   // Lấy ghi chú theo userId
//   Future<void> fetchNotes(int userId) async {
//     final userNotes = await DatabaseService().getNotesByUserId(userId);
//     notes.assignAll(userNotes);
//   }

//   // Thêm ghi chú mới và làm mới danh sách
//   Future<void> addNote(Note note) async {
//     final noteId = await _dbService.insertNote(note);
//     notes.add(Note(
//       id: noteId,
//       title: note.title,
//       content: note.content,
//       createdAt: note.createdAt,
//       userId: note.userId,
//     ));
//   }

//   // Xóa ghi chú theo id và làm mới danh sách
//   Future<void> deleteNoteById(int id) async {
//     await _dbService.deleteNoteById(id);
//     notes.removeWhere((note) => note.id == id); // Xóa ghi chú khỏi danh sách
//   }

//   // Cập nhật ghi chú và làm mới danh sách
//   Future<void> updateNote(Note note) async {
//     await _dbService.updateNote(note);
//     final index = notes.indexWhere((n) => n.id == note.id);
//     if (index != -1) {
//       notes[index] = note; // Cập nhật ghi chú trong danh sách
//     }
//   }
// }
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