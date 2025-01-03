import 'package:flutter_notes_app/models/habit.dart';
import 'package:flutter_notes_app/services/database_service.dart';
import 'package:get/get.dart';

class HabitController extends GetxController {
  final _db = DatabaseService.instance;
  
  // Observable lists
  final _habits = <Habit>[].obs;
  var progress = <int, double>{}.obs; // Tiến độ của từng habit
  var completedToday = <int, bool>{}.obs; // Trạng thái hoàn thành hôm nay
  final _activeHabits = <Habit>[].obs;
  final _completedHabits = <Habit>[].obs;
  
  // Loading states
  final _isLoading = false.obs;
  final _isCreating = false.obs;
  final _isUpdating = false.obs;

  

  // Getters
  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _activeHabits;
  List<Habit> get completedHabits => _completedHabits;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;

  // HabitController(this._db);

  @override
  void onInit() {
    super.onInit();
    // You can load initial data here if needed
  }

  Future<void> loadUserHabits(int userId) async {
    try {
      _isLoading.value = true;
      final allHabits = await _db.getHabits(userId);
      _habits.assignAll(allHabits);
      
      // Filter active and completed habits
      _activeHabits.assignAll(
        allHabits.where((habit) => 
          !habit.isCompleted && 
          (habit.endDate == null || habit.endDate!.isAfter(DateTime.now()))
        )
      );
      
      _completedHabits.assignAll(
        allHabits.where((habit) => habit.isCompleted)
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load habits: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createHabit({
    required int userId,
    required String title,
    required String description,
    required int targetDays,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      _isCreating.value = true;
      final habit = Habit(
        userId: userId,
        title: title,
        description: description,
        targetDays: targetDays,
        startDate: startDate,
        endDate: endDate,
      );
      
      final id = await _db.createHabit(habit);
      habit.id = id;
      
      _habits.add(habit);
      _activeHabits.add(habit);
    } catch (e) {
    } finally {
      _isCreating.value = false;
    }
  }

  

  Future<void> updateHabit(Habit habit) async {
    try {
      _isUpdating.value = true;
      await _db.updateHabit(habit);
      
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
      
      // Update active and completed lists
      if (habit.isCompleted) {
        _activeHabits.removeWhere((h) => h.id == habit.id);
        if (!_completedHabits.any((h) => h.id == habit.id)) {
          _completedHabits.add(habit);
        }
      } else {
        _completedHabits.removeWhere((h) => h.id == habit.id);
        if (!_activeHabits.any((h) => h.id == habit.id) &&
            (habit.endDate == null || habit.endDate!.isAfter(DateTime.now()))) {
          _activeHabits.add(habit);
        }
      }
      
      // Update progress and completedToday
      updateProgress(habit.id!, habit.completedDates.length / habit.targetDays);
      updateCompletedToday(habit.id!, false);

      Get.snackbar(
        'Success',
        'Habit updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update habit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isUpdating.value = false;
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _db.deleteHabit(habitId);
      
      _habits.removeWhere((h) => h.id == habitId);
      _activeHabits.removeWhere((h) => h.id == habitId);
      _completedHabits.removeWhere((h) => h.id == habitId);

      Get.snackbar(
        'Success',
        'Habit deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete habit: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateProgress(int habitId, double newProgress) {
    progress[habitId] = newProgress;
  }

  void updateCompletedToday(int habitId, bool isCompleted) {
    completedToday[habitId] = isCompleted;
  }

Future<void> markCompletion(int habitId, DateTime date) async {
  await _db.markHabitAsCompleted(habitId, date); // Hàm xử lý trong DB

  // Cập nhật danh sách thói quen trong controller
  final index = habits.indexWhere((habit) => habit.id == habitId);
  if (index != -1) {
    habits[index].completedDates.add(date); // Thêm ngày vào danh sách
    _habits.refresh(); // Cập nhật Obx
  }


  final habit = await _db.getHabit(habitId);
    // Update active and completed lists
  if (habit!.isCompleted) {
    _activeHabits.removeWhere((h) => h.id == habit.id);
    if (!_completedHabits.any((h) => h.id == habit.id)) {
      _completedHabits.add(habit);
    }
  } else {
    _completedHabits.removeWhere((h) => h.id == habit.id);
    if (!_activeHabits.any((h) => h.id == habit.id) &&
        (habit.endDate == null || habit.endDate!.isAfter(DateTime.now()))) {
      _activeHabits.add(habit);
    }
  }

  updateProgress(habitId, habits[index].completedDates.length / habits[index].targetDays);
  updateCompletedToday(habitId, true);
}


  Future<void> unmarkCompletion(int habitId, DateTime date) async {
    try {
      await _db.unmarkHabitAsCompleted(habitId, date);
      await _refreshHabit(habitId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to unmark completion: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    final index = habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      habits[index].completedDates.remove(date); // Thêm ngày vào danh sách
      _habits.refresh(); // Cập nhật Obx
    }
    updateProgress(habitId, habits[index].completedDates.length / habits[index].targetDays);
    updateCompletedToday(habitId, false);
  }

  // Helper method to refresh a single habit
  Future<void> _refreshHabit(int habitId) async {
    final updatedHabit = await _db.getHabit(habitId);
    if (updatedHabit != null) {
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
      
      if (updatedHabit.isCompleted) {
        _activeHabits.removeWhere((h) => h.id == habitId);
        if (!_completedHabits.any((h) => h.id == habitId)) {
          _completedHabits.add(updatedHabit);
        }
      } else {
        _completedHabits.removeWhere((h) => h.id == habitId);
        if (!_activeHabits.any((h) => h.id == habitId) &&
            (updatedHabit.endDate == null || updatedHabit.endDate!.isAfter(DateTime.now()))) {
          _activeHabits.add(updatedHabit);
        }
      }
    }
  }

  Future<int> getCurrentStreak(int habitId) async {
    try {
      return await _db.calculateCurrentStreak(habitId);
    } catch (e) {
      print('Error calculating streak: $e');
      return 0;
    }
  }


  double getCompletionRate(int habitId) {
    final habit = _habits.firstWhereOrNull((h) => h.id == habitId);
    if (habit == null) return 0.0;
    return habit.completedDates.length / habit.targetDays;
  }

  Future<int> getLongestStreak(int habitId) async {
    try {
      return await _db.calculateLongestStreak(habitId);
    } catch (e) {
      print('Error calculating longest streak: $e');
      return 0;
    }
  }

  Future<bool> isCompletedToday(int habitId) async {
    final today = DateTime.now();
    print('Checking if habit $habitId is completed today: $today');

    // Lấy danh sách completedDates từ database
    final completedDates = await _db.getCompletedDates(habitId);

    // Kiểm tra xem ngày hôm nay có trong completedDates không
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

}