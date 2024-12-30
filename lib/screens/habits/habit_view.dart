import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/habits/add_habit_view.dart';
import 'package:get/get.dart';
import 'package:flutter_notes_app/controllers/habit_controller.dart';
import 'package:flutter_notes_app/models/habit.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';


class HabitView extends StatelessWidget {
  final _habitController = Get.find<HabitController>();
  final _authController = Get.find<AuthController>();


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Habits'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // TODO: Navigate to add habit screen
                Get.to(() => HabitAddView());
              },
            ),
          ],
        ),
        body: Obx(
          () => _habitController.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _buildActiveHabits(),
                    _buildCompletedHabits(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildActiveHabits() {
    return Obx(() {
      final activeHabits = _habitController.activeHabits;
      if (activeHabits.isEmpty) {
        return Center(
          child: Text('No active habits. Create one to get started!'),
        );
      }
      return ListView.builder(
        itemCount: activeHabits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(activeHabits[index]);
        },
      );
    });
  }

  Widget _buildCompletedHabits() {
    return Obx(() {
      final completedHabits = _habitController.completedHabits;
      if (completedHabits.isEmpty) {
        return Center(
          child: Text('No completed habits yet. Keep going!'),
        );
      }
      return ListView.builder(
        itemCount: completedHabits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(completedHabits[index]);
        },
      );
    });
  }


  Widget _buildHabitCard(Habit habit) {
    final progress = _habitController.getProgressPercentage(habit);
    final isCompletedToday = _habitController.isCompletedToday(habit);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        habit.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                CircularPercentIndicator(
                  radius: 30,
                  lineWidth: 5,
                  percent: progress,
                  center: Text('${(progress * 100).toInt()}%'),
                  progressColor: Theme.of(Get.context!).primaryColor,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${habit.completedDates.length}/${habit.targetDays} days',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                if (!habit.isCompleted)
                  ElevatedButton.icon(
                    icon: Icon(
                      isCompletedToday ? Icons.check_circle : Icons.check,
                    ),
                    label: Text(
                      isCompletedToday ? 'Completed' : 'Mark Complete',
                    ),
                    onPressed: isCompletedToday
                        ? null
                        : () => _habitController.markHabitCompleted(habit.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompletedToday ? Colors.grey : null,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            FutureBuilder<int>(
              future: _habitController.getCurrentStreak(habit.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                return Text(
                  'Current streak: ${snapshot.data} days',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}