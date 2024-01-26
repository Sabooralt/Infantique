import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    await ProfileController.updateProfile(context, _nameController, _emailController);
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
              backgroundColor: Colors.transparent,
              backgroundImage: ProfileController.pickedImage != null
                  ? FileImage(File(ProfileController.pickedImage!.path)) as ImageProvider<Object>?
                  : NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        // Call a function to pick the image
                        XFile? pickedImage = await ProfileController.pickImage(context);
                        if (pickedImage != null) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            /*   CircleAvatar(
              radius: 50,
              foregroundImage: ProfileController.pickedImage != null
                  ? FileImage(File(ProfileController.pickedImage!.path)) as ImageProvider<Object>?
                  : NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? '') as ImageProvider<Object>?,
              child: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  // Call a function to pick the image
                  XFile? pickedImage = await ProfileController.pickImage(context);
                  if (pickedImage != null) {
                    setState(() {});
                  }
                },
              ),
            ),*/
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
