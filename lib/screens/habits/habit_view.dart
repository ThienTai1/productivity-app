
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:flutter_notes_app/controllers/habit_controller.dart';
import 'package:flutter_notes_app/models/habit.dart';
import 'package:flutter_notes_app/screens/habits/add_habit_view.dart';
import 'package:flutter_notes_app/widgets/app_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HabitView extends StatefulWidget {
  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  final _habitController = Get.find<HabitController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserHabits();

      // Reload habits when app resumes
      SystemChannels.lifecycle.setMessageHandler((msg) {
        if (msg == AppLifecycleState.resumed.toString()) {
          _loadUserHabits();
        }
        return Future.value(msg);
      });
    });
  }

  void _loadUserHabits() {
    if (_authController.currentUser.value?.id != null) {
      _habitController.loadUserHabits(_authController.currentUser.value!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Habits'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.to(HabitAddView()),
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: Obx(
          () => _habitController.isLoading
              ? const Center(child: CircularProgressIndicator())
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
      if (_habitController.activeHabits.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.sentiment_neutral, size: 48),
              const SizedBox(height: 16),
              const Text('No active habits yet'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Get.to(HabitAddView()),
                child: const Text('Create your first habit'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _habitController.activeHabits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(_habitController.activeHabits[index]);
        },
      );
    });
  }

  Widget _buildCompletedHabits() {
    return Obx(() {
      if (_habitController.completedHabits.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 48),
              SizedBox(height: 16),
              Text('No completed habits yet'),
              SizedBox(height: 8),
              Text('Keep going with your active habits!'),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _habitController.completedHabits.length,
        itemBuilder: (context, index) {
          return _buildHabitCard(
            _habitController.completedHabits[index],
            isCompleted: true,
          );
        },
      );
    });
  }

  Widget _buildHabitCard(Habit habit, {bool isCompleted = false}) {
    return Obx(() {
      final progress = _habitController.progress[habit.id] ?? 0.0;
      final isCompletedToday =
          _habitController.completedToday[habit.id] ?? false;
      final isCompleted = habit.completedDates.length >= habit.targetDays;
      final currentHabit = _habitController.habits
                  .firstWhereOrNull((h) => h.id == habit.id);

      return GestureDetector(
          onTap: () {
            Get.toNamed('/habits/detail', arguments: habit);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              currentHabit!.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentHabit.description,
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
                        progressColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                      '${currentHabit.completedDates.length}/${currentHabit.targetDays} days',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (!isCompleted)
                        ElevatedButton.icon(
                          icon: Icon(
                            isCompletedToday ? Icons.check_circle : Icons.check,
                          ),
                          label: Text(
                            isCompletedToday ? 'Completed' : 'Mark Complete',
                          ),
                          onPressed: isCompletedToday
                              ? () => _habitController.unmarkCompletion(
                                    habit.id!,
                                    DateTime.now(),
                              )
                              : () => _habitController.markCompletion(
                                    habit.id!,
                                    DateTime.now(),
                                  ),
                          style: ElevatedButton.styleFrom(
                            // backgroundColor:
                            //     isCompletedToday ? Colors.grey : null,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start date: ${DateFormat('MMM dd, yyyy').format(currentHabit.startDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    'End date: ${DateFormat('MMM dd, yyyy').format(currentHabit.endDate!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ));
    });
  }
}
