import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile/profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.person),
  //           onPressed: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute<ProfileScreen>(
  //                 builder: (context) => ProfileScreen(
  //                   appBar: AppBar(
  //                     title: const Text('User Profile'),
  //                   ),
  //                   actions: [
  //                     SignedOutAction((context) {
  //                       Navigator.of(context).pop();
  //                     })
  //                   ],
  //                   children: [
  //                     const Divider(),
  //                     Padding(
  //                       padding: const EdgeInsets.all(2),
  //                       child: AspectRatio(
  //                         aspectRatio: 1,
  //                         child: Image.asset('flutterfire_300x.png'),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         )
  //       ],
  //       automaticallyImplyLeading: false,
  //     ),
  //     body: Center(
  //       child: Column(
  //         children: [
  //           Image.asset('dash.png'),
  //           Text(
  //             'Welcome!',
  //             style: Theme.of(context).textTheme.displaySmall,
  //           ),
  //           const SignOutButton(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedPhysiqueGoal;
  String? _selectedGender; // New field for Gender
  DateTime? _selectedBirthday;

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

  @override
  void initState() {
    super.initState();
  }

  void _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // _emailController.text = currentUser.email ?? '';

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
          _selectedGender = data['gender']; // Load gender
          // Load birthday if available
          if (data['birthday'] is Timestamp) {
            _selectedBirthday = (data['birthday'] as Timestamp).toDate();
          } else if (data['birthday'] is String) {
            // Handle if saved as string
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
      // if (_emailController.text != currentUser.email) {
      //   // This is a simplified attempt. For production, use re-authentication.
      //   try {
      //     await currentUser.verifyBeforeUpdateEmail(_emailController.text);
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //           content: Text(
      //               'Email update link sent to new email. Verify to complete.'),
      //           backgroundColor: Colors.orange),
      //     );
      //   } on FirebaseAuthException catch (e) {
      //     print("Error updating email: ${e.code} - ${e.message}");
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //           content: Text('Failed to update email: ${e.message}'),
      //           backgroundColor: Colors.red),
      //     );
      //   }
      // }

      // // Update password if a NEW password is provided
      // if (_passwordController.text.isNotEmpty) {
      //   try {
      //     await currentUser.updatePassword(_passwordController.text);
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //           content: Text('Password updated successfully!'),
      //           backgroundColor: Colors.green),
      //     );
      //     _passwordController.clear(); // Clear field after successful update
      //   } on FirebaseAuthException catch (e) {
      //     print("Error updating password: ${e.code} - ${e.message}");
      //     // Common error: 'requires-recent-login'
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //           content: Text(
      //               'Failed to update password: ${e.message}. Please log out and back in if this persists.'),
      //           backgroundColor: Colors.red),
      //     );
      //   }
      // }

      // 2. Save Custom Fitness Data to Firestore
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
          //FIREBSE ACCOUNT
          //======================================================FIREBASE ACCOUNT
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Firebase Account Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('Firebase Account'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop(); // Pops the ProfileScreen
                      }),
                    ],
                    children: const [],
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

              // FirebaseUI Sign Out Button (optional, as you have it in MainNavigationView's AppBar too)
              const SignOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}
