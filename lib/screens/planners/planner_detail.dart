import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/planner_controller.dart';
import 'package:flutter_notes_app/models/planner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PlannerDetailScreen extends StatelessWidget {
  final Planner planner;
  final PlannerController _plannerController = Get.find<PlannerController>();

  PlannerDetailScreen({required this.planner});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planner Detail'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailCard(),
            SizedBox(height: 20),
            _buildCompletionStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    planner.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
                SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(planner.date),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              planner.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d, y').format(planner.date),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionStatus() {
    return Card(
      elevation: 4,
      child: ListTile(
        title: Text('Status'),
        subtitle: Text(planner.isCompleted ? 'Completed' : 'Pending'),
        trailing: Switch(
          value: planner.isCompleted,
          onChanged: (bool value) {
            _plannerController.toggleComplete(planner);
            Get.back(); // Return to previous screen after toggling
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: planner.title);
    final descriptionController = TextEditingController(text: planner.description);
    DateTime selectedDate = planner.date;

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
                subtitle: Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(selectedDate),
                ),
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
                  final updatedPlanner = Planner(
                    id: planner.id,
                    userId: planner.userId,
                    title: titleController.text,
                    description: descriptionController.text,
                    date: selectedDate,
                    isCompleted: planner.isCompleted,
                  );
                  await _plannerController.updatePlanner(updatedPlanner);
                  Get.back();
                  Get.back();
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Planner'),
        content: Text('Are you sure you want to delete this planner?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _plannerController.deletePlanner(planner.id!);
              Get.back();
              Get.back();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}