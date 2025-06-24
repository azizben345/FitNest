import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddWorkoutPage extends StatefulWidget {
  final String userId; 

  const AddWorkoutPage({super.key, required this.userId});

  @override
  State<AddWorkoutPage> createState() => _AddWorkoutPageState();
}

class _AddWorkoutPageState extends State<AddWorkoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // default to current date/time
  String? _selectedActivity;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // list of activitiy types
  final List<String> recentActivities = ['Aerobics', 'Jogging'];
  final List<String> popularActivities = [
    'Walking',
    'Cycling',
    'Strength training',
    'Aerobics',
    'American football',
    'Australian football',
    'Badminton',
    'Baseball',
    'Basketball'
  ];

  List<String> get allActivities => [...recentActivities, ...popularActivities];

  Future<void> _saveWorkout() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('workoutHistory').add({
          'uid': widget.userId,
          'activityType': _selectedActivity,
          'duration': int.parse(_durationController.text.trim()),
          'caloriesExpended': double.parse(_caloriesController.text.trim()),
          'timestamp': Timestamp.fromDate(_selectedDate),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout saved successfully!'))
        );
        Navigator.pop(context);  // Go back after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Activity Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedActivity,
                hint: const Text('Select Activity'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedActivity = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Select an activity';
                  return null;
                },
                items: allActivities.map<DropdownMenuItem<String>>((String activity) {
                  return DropdownMenuItem<String>(
                    value: activity,
                    child: Text(activity),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // duration input
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter duration';
                  final n = int.tryParse(value);
                  if (n == null || n <= 0) return 'Enter a valid duration';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // caloriesExpended input
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories Expended',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter calories';
                  final n = double.tryParse(value);
                  if (n == null || n < 0) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // timestamp selector
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                    Text(
                    'Timestamp: ${DateFormat.yMd().add_jm().format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      DateTime now = DateTime.now();
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(now.year, now.month, now.day),
                      );
                      if (picked != null && picked != _selectedDate) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // save Button
              ElevatedButton(
                onPressed: _saveWorkout,
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
