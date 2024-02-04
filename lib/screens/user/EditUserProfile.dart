import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infantique/controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await ProfileController.loadUserData(_nameController, _emailController);
  }

  Future<void> _updateProfile() async {
    await ProfileController.updateProfile(
        context, _nameController, _emailController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: ClipOval(
                child: ProfileController.pickedImage != null
                    ? Image.file(
                        File(ProfileController.pickedImage!.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      )
                    : Image.network(
                        FirebaseAuth.instance.currentUser?.photoURL ?? '',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Call a function to pick the image
                await ProfileController.pickImage(context);
                setState(() {});
              },
              child: const Text('Change Profile Picture'),
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Call a function to update the profile
                _updateProfile();
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
