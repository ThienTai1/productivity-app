import 'package:flutter/material.dart';
import 'package:flutter_notes_app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HabitAddView extends StatefulWidget {

  
  @override
  _HabitAddViewState createState() => _HabitAddViewState();
}

class _HabitAddViewState extends State<HabitAddView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetDaysController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  
  final _authController = Get.find<AuthController>();
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Target Days field
                TextFormField(
                  controller: _targetDaysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Days',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the target days';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Start Date picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _startDate == null
                            ? 'Start Date: Not selected'
                            : 'Start Date: ${DateFormat.yMMMd().format(_startDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                          });
                        }
                      },
                      child: Text('Select'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // End Date picker
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _endDate == null
                            ? 'End Date: Not selected'
                            : 'End Date: ${DateFormat.yMMMd().format(_endDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _endDate = picked;
                          });
                        }
                      },
                      child: Text('Select'),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                // Submit button
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please select a start date')),
                          );
                          return;
                        }

                        // Save habit to database
                        final habit = {
                          'title': _titleController.text,
                          'description': _descriptionController.text,
                          'targetDays': int.parse(_targetDaysController.text),
                          'startDate': _startDate!.toIso8601String(),
                          'endDate': _endDate?.toIso8601String(),
                          'isCompleted': 0,
                          'userId': _authController.currentUser.value?.id, // Replace with actual user ID
                        };

                        try {
                          // Replace with your database service call
                          await saveHabitToDatabase(habit);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Habit added successfully')),
                          );
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding habit: $e')),
                          );
                        }
                      }
                    },
                    child: Text('Add Habit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveHabitToDatabase(Map<String, dynamic> habit) async {
    // Implement database insert logic here
    // Example: await db.insert('habits', habit);
    print('Saving habit to database: $habit');
  }
}
