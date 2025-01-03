import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:flutter_notes_app/controllers/planner_controller.dart';
import 'package:flutter_notes_app/models/planner.dart';
import 'package:flutter_notes_app/widgets/app_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends StatefulWidget {
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final _plannerController = Get.find<PlannerController>();
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlanners();
    });
  }

  void _loadPlanners() {
    if (_authController.currentUser.value?.id != null) {
      _plannerController.loadPlanners(_authController.currentUser.value!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Planner'),
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        final groupedPlanners = _groupPlannersByDate();
        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: groupedPlanners.length,
          itemBuilder: (context, index) {
            final date = groupedPlanners.keys.elementAt(index);
            final planners = groupedPlanners[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateHeader(date),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                ...planners.map((planner) => _buildPlannerCard(planner)),
                SizedBox(height: 16),
              ],
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlannerDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  Map<DateTime, List<Planner>> _groupPlannersByDate() {
    final grouped = <DateTime, List<Planner>>{};
    for (var planner in _plannerController.planners) {
      final date = DateTime(
        planner.date.year,
        planner.date.month,
        planner.date.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(planner);
    }
    return Map.fromEntries(
        grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${_getDayOfWeek(date.weekday)}, ${_getMonth(date.month)} ${date.day}, ${date.year}';
    }
  }

  String _getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }


  Widget _buildPlannerCard(Planner planner) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () => Get.toNamed('/planner/detail', arguments: planner),
        leading: Checkbox(
          value: planner.isCompleted,
          onChanged: (bool? value) {
            _plannerController.toggleComplete(planner);
          },
        ),
        title: Text(
          planner.title,
          style: TextStyle(
            decoration: planner.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(planner.description),
            Text(
              DateFormat('HH:mm').format(planner.date),
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddPlannerDialog(planner: planner);
            } else if (value == 'delete') {
              _plannerController.deletePlanner(planner.id!);
            }
          },
        ),
      ),
    );
  }

  void _showAddPlannerDialog({Planner? planner}) {
    final titleController = TextEditingController(text: planner?.title ?? '');
    final descriptionController =
        TextEditingController(text: planner?.description ?? '');
    DateTime selectedDate = planner?.date ?? DateTime.now();

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
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Date & Time'),
                subtitle:
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDate),
                    );
                    if (time != null) {
                      selectedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (planner != null) {
                    final updatedPlanner = Planner(
                      id: planner.id,
                      userId: planner.userId,
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                      isCompleted: planner.isCompleted,
                    );
                    await _plannerController.updatePlanner(updatedPlanner);
                  } else {
                    final newPlanner = Planner(
                      userId: _authController.currentUser.value!.id!,
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                    );
                    await _plannerController.addPlanner(newPlanner);
                  }
                  Get.back();
                },
                child: Text(planner != null ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
