import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/controllers/habit_controller.dart';
import 'package:flutter_notes_app/models/habit.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';

class HabitDetailView extends StatelessWidget {
  final _habitController = Get.find<HabitController>();
  final _authController = Get.find<AuthController>();
  // Định nghĩa Rx variables để quản lý state
  final Rx<DateTime> startDate;
  final Rx<DateTime> endDate;

  final Habit habit;
  HabitDetailView({required this.habit})
      : startDate = habit.startDate.obs,
        endDate = (habit.endDate ?? DateTime.now()).obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              SizedBox(height: 24),
              _buildProgressSection(),
              SizedBox(height: 24),
              _buildStatisticsSection(),
              SizedBox(height: 24),
              _buildCompletionHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Obx(() {
      final currentHabit = _habitController.habits
            .firstWhereOrNull((h) => h.id == habit.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentHabit!.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            currentHabit.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProgressSection() {
    return Obx(() {
      final progress = _habitController.progress[habit.id] ?? 0.0;
      final isCompletedToday =
          _habitController.completedToday[habit.id] ?? false;

      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Sử dụng Obx để theo dõi sự thay đổi của habits list
              Obx(() {
                final currentHabit = _habitController.habits
                    .firstWhereOrNull((h) => h.id == habit.id);

                if (currentHabit == null) {
                  return Center(
                    child: Text(
                      'This habit has been deleted.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return Center(
                child: Column(
                  children: [
                    CircularPercentIndicator(
                      radius: 60,
                      lineWidth: 10,
                      percent: progress,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Complete',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      progressColor: Theme.of(Get.context!).primaryColor,
                    ),
                    SizedBox(height: 16),
                    if (!currentHabit.isCompleted)
                      ElevatedButton.icon(
                        icon: Icon(
                          isCompletedToday ? Icons.check_circle : Icons.check,
                        ),
                        label: Text(
                          isCompletedToday
                              ? 'Completed Today'
                              : 'Mark Complete for Today',
                        ),
                        onPressed: isCompletedToday
                            ? () => _habitController.unmarkCompletion(
                                    habit.id!,
                                    DateTime.now(),
                              )
                            : () => _habitController.markCompletion(
                                currentHabit.id!, DateTime.now()),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                      ),
                  ],
                ));
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatisticsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              final currentHabit = _habitController.habits
                  .firstWhereOrNull((h) => h.id == habit.id);

              if (currentHabit == null) {
                return Center(
                  child: Text(
                    'This habit has been deleted.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total Days',
                    '${currentHabit.completedDates.length}/${currentHabit.targetDays}',
                    Icons.calendar_today,
                  ),
                  StreamBuilder<int>(
                    stream: Stream.periodic(Duration(milliseconds: 100))
                        .take(1)
                        .asyncMap((_) => _habitController
                            .getCurrentStreak(currentHabit.id!)),
                    builder: (context, snapshot) {
                      return _buildStatItem(
                        'Current Streak',
                        '${snapshot.data ?? 0} days',
                        Icons.local_fire_department,
                      );
                    },
                  ),
                  StreamBuilder<int>(
                    stream: Stream.periodic(Duration(milliseconds: 100))
                        .take(1)
                        .asyncMap((_) => _habitController
                            .getLongestStreak(currentHabit.id!)),
                    builder: (context, snapshot) {
                      return _buildStatItem(
                        'Best Streak',
                        '${snapshot.data ?? 0} days',
                        Icons.emoji_events,
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(Get.context!).primaryColor),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionHistorySection() {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              final currentHabit = _habitController.habits
                  .firstWhereOrNull((h) => h.id == habit.id);

              if (currentHabit == null) {
                return Center(
                  child: Text(
                    'This habit has been deleted.',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final sortedDates = currentHabit.completedDates.toList()
                ..sort((a, b) => b.compareTo(a));

              if (sortedDates.isEmpty) {
                return Center(
                  child: Text(
                    'No completion history yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(dateFormat.format(sortedDates[index])),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: habit.title);
    final TextEditingController descriptionController =
        TextEditingController(text: habit.description);

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Start Date picker với Obx
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Start Date: ${DateFormat.yMMMd().format(startDate.value)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate.value,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            startDate.value = picked;
                          }
                        },
                        child: Text('Select'),
                      ),
                    ],
                  )),
              SizedBox(height: 16),
              // End Date picker với Obx
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: Text(
                          'End Date: ${DateFormat.yMMMd().format(endDate.value)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: endDate.value,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            endDate.value = picked;
                          }
                        },
                        child: Text('Select'),
                      ),
                    ],
                  )),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  // Tính toán lại số ngày mục tiêu (targetDays)
                  final targetDays =
                      endDate.value.difference(startDate.value).inDays;

                  // Tính toán lại tiến độ dựa trên số ngày đã hoàn thành
                  final progress = habit.completedDates.length / targetDays;

                  // Cập nhật Habit với ngày mới và số ngày mục tiêu mới
                  final updatedHabit = Habit(
                    id: habit.id,
                    userId: _authController.currentUser.value!.id!,
                    title: titleController.text,
                    description: descriptionController.text,
                    targetDays: targetDays,
                    startDate: startDate.value,
                    endDate: endDate.value,
                  );

                  // Cập nhật thói quen trong controller
                  _habitController.updateHabit(updatedHabit);

                  // Cập nhật lại progress trong controller
                  _habitController.updateProgress(habit.id!, progress);

                  // Đóng dialog
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Habit'),
          content: Text(
              'Are you sure you want to delete this habit? This action cannot be undone.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _habitController.deleteHabit(habit.id!); // Delete the habit
                Get.back(); // Navigate back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }
}
