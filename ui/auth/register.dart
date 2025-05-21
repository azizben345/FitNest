import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';

  void _goToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Register', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.fitness_center, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Hello! Register to get\nstarted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Username
                        _buildInputField(
                          label: 'Username',
                          onSaved: (val) => username = val ?? '',
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Enter username'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildInputField(
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (val) => email = val ?? '',
                          validator:
                              (val) =>
                                  val == null || !val.contains('@')
                                      ? 'Enter a valid email'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildInputField(
                          label: 'Password',
                          obscureText: true,
                          onSaved: (val) => password = val ?? '',
                          validator:
                              (val) =>
                                  val == null || val.length < 6
                                      ? 'Password must be at least 6 characters'
                                      : null,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        _buildInputField(
                          label: 'Confirm Password',
                          obscureText: true,
                          onSaved: (val) => confirmPassword = val ?? '',
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (val != password) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Register button
                        Center(
                          child: SizedBox(
                            width: 200,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _formKey.currentState?.save();
                                  if (password != confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Passwords do not match'),
                                      ),
                                    );
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Registering $email'),
                                    ),
                                  );
                                  // Add registration logic here
                                }
                              },
                              child: const Text('Register'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom text with login link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white70),
                    ),
                    GestureDetector(
                      onTap: _goToLogin,
                      child: const Text(
                        'Login Now',
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Center(
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        ),
        child: TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // We removed underline border to create button-like style
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: validator,
        ),
      ),
    );
  }
}
