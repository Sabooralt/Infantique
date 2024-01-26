import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/screens/user/email_verification.dart';

class EmailVerificationSnackbar extends StatefulWidget {
  @override
  _EmailVerificationSnackbarState createState() => _EmailVerificationSnackbarState();
}

class _EmailVerificationSnackbarState extends State<EmailVerificationSnackbar> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    // Delay the execution of checkEmailVerificationStatus by 2 seconds
    Future.delayed(Duration(seconds: 5), () {
      checkEmailVerificationStatus();
    });
  }

  Future<void> checkEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      // If the email is not verified, show a Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('Please verify your email.'),
              const SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailVerificationScreen()),
                  );
                },
                child: Text('Verify Email'),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await user.sendEmailVerification();
        // Email sent successfully
      } catch (e) {
        // Handle errors
        print('Error sending verification email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder widget; no need to display anything here
  }
}
