import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/screens/user/email_verification.dart';

class EmailVerificationSnackbar extends StatefulWidget {
  const EmailVerificationSnackbar({super.key});

  @override
  _EmailVerificationSnackbarState createState() => _EmailVerificationSnackbarState();
}

class _EmailVerificationSnackbarState extends State<EmailVerificationSnackbar> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      checkEmailVerificationStatus();
    });
  }

  Future<void> checkEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null && !user.emailVerified) {
      // If the email is not verified, show a Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please verify your email.'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmailVerificationScreen(),
                    ),
                  );
                },
                child: const Text('Verify Email'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0), // Adjust the margin as needed
          action: SnackBarAction(
            label: '',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder widget; no need to display anything here
  }
}
