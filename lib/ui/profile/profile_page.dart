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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String? _selectedPhysiqueGoal;
  // put here for profile image

  final List<String> _physiqueGoals = [
    'Lose Weight',
    'Build Muscle',
    'Maintain Weight',
    'Athletic Performance',
    'Improve Endurance',
    'General Fitness',
  ];

  @override
  void initState() {
    super.initState();
  }

  void _loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _emailController.text = currentUser.email ?? '';

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
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
      if (_emailController.text != currentUser.email) {
        // This is a simplified attempt. For production, use re-authentication.
        try {
          await currentUser.verifyBeforeUpdateEmail(_emailController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Email update link sent to new email. Verify to complete.'),
                backgroundColor: Colors.orange),
          );
        } on FirebaseAuthException catch (e) {
          print("Error updating email: ${e.code} - ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update email: ${e.message}'),
                backgroundColor: Colors.red),
          );
        }
      }

      // Update password if a NEW password is provided
      if (_passwordController.text.isNotEmpty) {
        try {
          await currentUser.updatePassword(_passwordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Password updated successfully!'),
                backgroundColor: Colors.green),
          );
          _passwordController.clear(); // Clear field after successful update
        } on FirebaseAuthException catch (e) {
          print("Error updating password: ${e.code} - ${e.message}");
          // Common error: 'requires-recent-login'
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update password: ${e.message}. Please log out and back in if this persists.'),
                backgroundColor: Colors.red),
          );
        }
      }

      // 2. Save Custom Fitness Data to Firestore
      Map<String, dynamic> fitnessProfileData = {
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'targetWeight': double.tryParse(_targetWeightController.text),
        'physiqueGoal': _selectedPhysiqueGoal,
        'lastUpdated': FieldValue
            .serverTimestamp(), // Timestamp for when it was last updated
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'), // Title for the profile page
        actions: [
          // Button to navigate to FirebaseUI ProfileScreen for core auth settings
          IconButton(
            icon: const Icon(Icons.settings), // Icon for Firebase settings
            tooltip: 'Firebase Account Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text(
                          'Firebase Account'), // Title for FirebaseUI screen
                    ),
                    actions: [
                      SignedOutAction((context) {
                        // This action runs when the user signs out from the FirebaseUI ProfileScreen
                        Navigator.of(context).pop(); // Pops the ProfileScreen
                        // You might want to navigate to a sign-in/welcome screen here
                        // For example: Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
                      }),
                    ],
                    children: const [
                      // Optional: Add custom widgets below the FirebaseUI profile sections
                      // const Divider(),
                      // Padding(
                      //   padding: const EdgeInsets.all(2),
                      //   child: AspectRatio(
                      //     aspectRatio: 1,
                      //     child: Image.asset('assets/flutterfire_300x.png'), // Example
                      //   ),
                      // ),
                    ],
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
              // Profile Image Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    GestureDetector(
                      // Tap to pick image
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            AssetImage('assets/profile_pic_default.jpg'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your Fitness Profile',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                Colors.white, // Ensure theme colors are applied
                          ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Tap the circle to change your profile picture',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Password Field (Again, be cautious with this in a real app)
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
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
