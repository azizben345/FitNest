import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  String? _profileImageUrl;
  bool _isUploading = false;

  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        setState(() {
          _profileImageUrl = data['profileImage'];
        });
      }
    }
  }

  Future<void> _pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() => _isUploading = true); // ✅ START spinner

      _webImageBytes = result.files.single.bytes!;

      try {
        final user = FirebaseAuth.instance.currentUser;
        final ref = FirebaseStorage.instance.ref('profileImages/${user!.uid}');
        await ref.putData(_webImageBytes!); // ✅ upload from memory
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(user.uid)
            .set({
          'name': _nameController.text.trim(),
          'profileImage': url,
        }, SetOptions(merge: true));

        setState(() {
          _profileImageUrl = url;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading image: $e")),
        );
      } finally {
        setState(() => _isUploading = false); // ✅ STOP spinner
      }
    }
  }

  Future<void> _saveName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('userProfiles')
        .doc(user.uid)
        .set({
      'name': _nameController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Name saved")));
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            if (_isUploading)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _saveName,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text("Sign out"),
            ),
          ],
        ),
      ),
    );
  }
}
