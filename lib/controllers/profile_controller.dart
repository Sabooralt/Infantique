import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';


class ProfileController {
  static XFile? _pickedImage; // Define a variable to store the picked image file

  // Add a getter for pickedImage
  static XFile? get pickedImage => _pickedImage;

  static Future<void> loadUserData(TextEditingController nameController, TextEditingController emailController) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      nameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
    }
  }

  static Future<void> updateProfile(BuildContext context, TextEditingController nameController, TextEditingController emailController) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      try {
        await user.updateDisplayName(nameController.text);
        await user.updateEmail(emailController.text);

        if (_pickedImage != null) {
          // Update the profile picture only if an image is picked
          String imageUrl = await _uploadImageToStorage(_pickedImage!.path);
          await _updateUserProfile(imageUrl);
          _pickedImage = null; // Reset picked image after updating
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
          ),
        );
      } catch (e) {
        print('Error updating name and email: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please verify your email before updating the profile.'),
          action: SnackBarAction(
            label: 'Verify Email',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/email_verification');
            },
          ),
        ),
      );
    }
  }

  static Future<XFile?> pickImage(BuildContext context) async {
    final picker = ImagePicker();
    XFile? pickedFile = await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Pick from gallery'),
              onTap: () async {
                Navigator.pop(context, await picker.pickImage(source: ImageSource.gallery));
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context, await picker.pickImage(source: ImageSource.camera));
              },
            ),
          ],
        );
      },
    );

    _pickedImage = pickedFile; // Set the picked image

    return pickedFile;
  }

  static Future<String> _uploadImageToStorage(String imagePath) async {
    Reference storageReference = FirebaseStorage.instance.ref().child('profile_pictures/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(File(imagePath));
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    return await taskSnapshot.ref.getDownloadURL();
  }

  static Future<void> _updateUserProfile(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await user?.updatePhotoURL(imageUrl);
      await user?.reload();
      // You need to handle state updates accordingly, you can use a callback or a state management solution.
    } catch (e) {
      print('Error updating profile picture: $e');
    }
  }
}
