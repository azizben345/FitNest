import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedPhysiqueGoal;
  String? _selectedGender; // New field for Gender
  DateTime? _selectedBirthday;
  String? _selectedActivityLevel;

  final List<String> _physiqueGoals = [
    'Lose Weight',
    'Build Muscle',
    'Maintain Weight',
    'Athletic Performance',
    'Improve Endurance',
    'General Fitness',
  ];

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _activityLevels = [
    'Sedentary: No exercise', // little to no exercise
    'Lightly Active: 1-3 days/week', // Light exercise/sports 1-3 days/week
    'Moderately Active: 3-5 days/week', // Moderate exercise/sports 3-5 days/week
    'Very Active: 6-7 days a week', // Hard exercise/sports 6-7 days a week
    'Extra Active', // Very hard exercise/physical job
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(currentUser.uid)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        _heightController.text = data['height']?.toString() ?? '';
        _weightController.text = data['weight']?.toString() ?? '';
        _targetWeightController.text = data['targetWeight']?.toString() ?? '';
        setState(() {
          _selectedPhysiqueGoal = data['physiqueGoal'];
          _selectedGender = data['gender'];
          _selectedActivityLevel = data['activityLevel'];
          if (data['birthday'] is Timestamp) {
            _selectedBirthday = (data['birthday'] as Timestamp).toDate();
          } else if (data['birthday'] is String) {
            try {
              _selectedBirthday = DateTime.parse(data['birthday']);
            } catch (e) {
              print("Error parsing birthday string: $e");
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    // _emailController.dispose();
    // _passwordController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to save your profile.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    try {
      double? currentWeight = double.tryParse(_weightController.text);
      double? targetWeight = double.tryParse(_targetWeightController.text);
      double weightLossTargetKgPerWeek = 0.0; // Default to 0

      // Calculate weightLossTargetKgPerWeek based on physique goal
      if (_selectedPhysiqueGoal == 'Lose Weight' &&
          currentWeight != null &&
          targetWeight != null) {
        if (currentWeight > targetWeight) {
          // A reasonable weekly loss for most healthy individuals.
          // You might want to let the user select this, or make it dynamic.
          weightLossTargetKgPerWeek = 0.5; // Example: 0.5 kg per week
        } else {
          // If current weight is not greater than target for 'Lose Weight',
          // this might indicate an error or a different goal,
          // so we set target loss to 0 to avoid negative calories.
          weightLossTargetKgPerWeek = 0.0;
        }
      } else if (_selectedPhysiqueGoal == 'Build Muscle' ||
          _selectedPhysiqueGoal == 'Maintain Weight') {
        // For building muscle or maintaining, we aim for maintenance or slight surplus.
        // We can set weightLossTargetKgPerWeek to a small negative value for gain, or 0 for maintenance
        // For calorie calculation, a positive deficit value means weight loss,
        // so for gain, we need a "negative deficit" (surplus).
        // Let's store a positive value for "target change".
        // The dashboard viewmodel's calorie calculation will interpret this.
        if (_selectedPhysiqueGoal == 'Build Muscle') {
          // Example: Aim for 0.25 kg gain per week (represented as -0.25 for a "negative loss target")
          weightLossTargetKgPerWeek = -0.25; // Indicates a calorie surplus goal
        } else {
          // Maintain Weight
          weightLossTargetKgPerWeek = 0.0; // No deficit/surplus goal
        }
      }

      // Save Custom Fitness Data to Firestore
      Map<String, dynamic> fitnessProfileData = {
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'targetWeight': double.tryParse(_targetWeightController.text),
        'physiqueGoal': _selectedPhysiqueGoal,
        'gender': _selectedGender, // Save gender
        'birthday': _selectedBirthday != null
            ? Timestamp.fromDate(_selectedBirthday!)
            : null, // Save birthday as Timestamp
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(currentUser.uid)
          .set(
              fitnessProfileData,
              SetOptions(
                  merge:
                      true)); // Use merge: true to update existing fields without overwriting the whole document

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Error saving profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  //Date Picker
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000), // Default to year 2000
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'), // Title for the profile page
        actions: [
          //Settings
          //======================================================Setting
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('Setting'),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch fields across width
            children: [
              // Email Field
              // TextFormField(
              //   controller: _emailController,
              //   decoration: const InputDecoration(
              //     labelText: 'Email',
              //     prefixIcon: Icon(Icons.email),
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.emailAddress,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your email';
              //     }
              //     if (!value.contains('@')) {
              //       return 'Please enter a valid email';
              //     }
              //     return null;
              //   },
              // ),

              // const SizedBox(height: 16),

              // // Password Field (Again, be cautious with this in a real app)
              // TextFormField(
              //   controller: _passwordController,
              //   decoration: const InputDecoration(
              //     labelText: 'Password',
              //     prefixIcon: Icon(Icons.lock),
              //     border: OutlineInputBorder(),
              //   ),
              //   obscureText: true,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your password';
              //     }
              //     if (value.length < 6) {
              //       return 'Password must be at least 6 characters';
              //     }
              //     return null;
              //   },
              // ),

              // const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                items: _genders.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Birthday Field
              InkWell(
                onTap: () => _selectBirthday(context), // Corrected call
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                    errorText: (_selectedBirthday == null &&
                            _formKey.currentState?.validate() == true)
                        ? 'Please select your birthday'
                        : null,
                  ),
                  baseStyle: Theme.of(context).textTheme.titleMedium,
                  child: Text(
                    _selectedBirthday == null
                        ? 'Select Date'
                        : '${_selectedBirthday!.toLocal()}'
                            .split(' ')[0], // Format date
                    style: TextStyle(
                      color: _selectedBirthday == null ? Colors.grey : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Height Field
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  prefixIcon: Icon(Icons.height),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 175',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Weight Field
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 70',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Target Weight Field
              TextFormField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 65',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your target weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Physique Goal Dropdown
              DropdownButtonFormField<String>(
                value: _selectedPhysiqueGoal,
                decoration: const InputDecoration(
                  labelText: 'Physique Goal',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                items: _physiqueGoals.map((String goal) {
                  return DropdownMenuItem<String>(
                    value: goal,
                    child: Text(goal),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPhysiqueGoal = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a physique goal';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // NEW: Activity Level Dropdown
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                decoration: const InputDecoration(
                  labelText: 'Activity Level',
                  prefixIcon: Icon(Icons.directions_run),
                  border: OutlineInputBorder(),
                ),
                items: _activityLevels.map((String level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedActivityLevel = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your activity level';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              // // FirebaseUI Sign Out Button (optional, as you have it in MainNavigationView's AppBar too)
              // const SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
