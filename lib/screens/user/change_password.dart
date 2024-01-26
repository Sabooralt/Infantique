import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _verifyAndUpdatePassword(context);
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyAndUpdatePassword(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // Verify the current password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: currentPasswordController.text,
      );

      await user?.reauthenticateWithCredential(credential);

      // Update the password
      await user?.updatePassword(newPasswordController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully!'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        // Current password doesn't match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Current password is incorrect. Please try again.'),
          ),
        );
      } else {
        // Other authentication-related errors
        print('Error updating password: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password. Please try again.'),
          ),
        );
      }
    } catch (e) {
      // Other general errors
      print('Error updating password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating password. Please try again.'),
        ),
      );
    }
  }
}
