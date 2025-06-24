import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'ui/authentication/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blueGrey
      ),
      // themeMode: _currentThemeMode,
      home: const AuthGate(),
    );
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // Base theme modified for dark background & button styles
//         scaffoldBackgroundColor: Colors.black,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.deepPurple,
//           brightness: Brightness.dark,
//           onPrimary:
//               Colors.black, // For button text color on primary background
//           primary: Colors.white, // We'll use white for button background
//         ),
//         useMaterial3: true,
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(color: Colors.white),
//           bodyMedium: TextStyle(color: Colors.white),
//           bodySmall: TextStyle(color: Colors.white),
//           headlineMedium: TextStyle(color: Colors.white),
//           titleLarge: TextStyle(color: Colors.white),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white, // white background
//             foregroundColor: Colors.black, // black text
//             textStyle: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             side: const BorderSide(color: Colors.white),
//             textStyle: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.black,
//           titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
//           iconTheme: IconThemeData(color: Colors.white),
//           centerTitle: true,
//           elevation: 0,
//         ),
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   void _goToLogin() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//     );
//   }

//   void _goToRegister() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const RegisterPage()),
//     );
//   }

//   void _continueAsGuest() {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Continuing as guest...')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.fitness_center,
//                 size: 100,
//                 color: Colors.white, // white icon
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Start your\nFitness Journey',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white, // white text
//                 ),
//               ),
//               const SizedBox(height: 40),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _goToLogin,
//                   child: const Text('Login'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: _goToRegister,
//                   child: const Text('Register'),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               GestureDetector(
//                 onTap: _continueAsGuest,
//                 child: const Text(
//                   'Continue as a guest',
//                   style: TextStyle(
//                     decoration: TextDecoration.underline,
//                     color: Colors.white, // white text for link
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }