import 'package:flutter_notes_app/models/habit.dart';
import 'package:flutter_notes_app/services/database_service.dart';
import 'package:get/get.dart';

class HabitController extends GetxController {
  final _db = DatabaseService.instance;
  final habits = <Habit>[].obs;
  final isLoading = false.obs;

  Future<void> loadHabits(int userId) async {
    try {
      isLoading.value = true;
      final habitList = await _db.getHabits(userId);
      habits.assignAll(habitList);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final newHabit = await _db.createHabit(habit);
      habits.insert(0, newHabit);
    } catch (e) {
      print('Error adding habit: $e');
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _db.updateHabit(habit);
      final index = habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        habits[index] = habit;
      }
    } catch (e) {
      print('Error updating habit: $e');
      rethrow;
    }
  }

  Future<void> deleteHabit(int id) async {
    try {
      await _db.deleteHabit(id);
      habits.removeWhere((habit) => habit.id == id);
    } catch (e) {
      print('Error deleting habit: $e');
      rethrow;
    }
  }

  Future<void> markHabitCompleted(int habitId) async {
    try {
      await _db.markHabitCompleted(habitId);
      final index = habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        final habit = habits[index];
        final today = DateTime.now();
        
        // Cập nhật danh sách completedDates
        habit.completedDates.add(today);
        
        // Kiểm tra nếu đã đạt mục tiêu
        if (habit.completedDates.length >= habit.targetDays) {
          habit.isCompleted = true;
          habit.endDate = today;
          await updateHabit(habit);
        }
        
        habits.refresh(); // Cập nhật UI
      }
    } catch (e) {
      print('Error marking habit as completed: $e');
      rethrow;
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

  // Helper methods
  List<Habit> get activeHabits => habits.where((h) => !h.isCompleted).toList();
  
  List<Habit> get completedHabits => habits.where((h) => h.isCompleted).toList();
  
  double getProgressPercentage(Habit habit) {
    if (habit.targetDays == 0) return 0.0;
    return (habit.completedDates.length / habit.targetDays).clamp(0.0, 1.0);
  }

  bool isCompletedToday(Habit habit) {
    final today = DateTime.now();
    return habit.completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

}