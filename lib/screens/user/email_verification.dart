import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Verification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildVerificationContent(context),
        ),
      ),
    );
  }

  Widget _buildVerificationContent(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder(
      future: user?.reload(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while waiting for email verification
          return CircularProgressIndicator();
        } else {
          // Email verification completed
          if (user?.emailVerified == true) {
            // Show SnackBar with success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email verified successfully!'),
              ),
            );

            // Navigate back to the previous screen after a short delay
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });

            return Text('Email verification completed!');
          } else {
            // User's email is not verified
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please verify your email to continue.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _sendEmailVerification(context);
                  },
                  child: Text('Resend Verification Email'),
                ),
              ],
            );
          }
        }
      },
    );
  }

  Future<void> _sendEmailVerification(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent. Please check your inbox.'),
        ),
      );
    } catch (e) {
      print('Error sending verification email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending verification email. Please try again.'),
        ),
      );
    }
  }
}
