import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/controllers/seller_controller.dart';
import 'package:infantique/screens/sellers/Seller_Panel.dart';



class Seller {
  final String id;
  final String name;

  Seller({required this.id, required this.name});
}

class SellerAuthPage extends StatefulWidget {
  @override
  _SellerAuthPageState createState() => _SellerAuthPageState();
}

class _SellerAuthPageState extends State<SellerAuthPage> {
  final SellerAuthController _authController = SellerAuthController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSignIn = true;

  Future<void> _toggleAuthMode() async {
    if (_isSignIn) {
      await _authController.signOut();
    }
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  void _submitForm() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    String name = _nameController.text;

    try {
      if (_isSignIn) {
        // Sign In
        User user = await _authController.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SellerPanel(user: user)),
        );
        // Sign in successful, navigate to the next screen or perform any other actions
      } else {
        // Sign Up
        await _authController.signUp(email, password, name: name);
        // Sign up successful, navigate to the next screen or perform any other actions
      }
    } catch (e) {
      // Handle authentication errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('$e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }



  String? _sellerName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignIn ? 'Seller Sign In' : 'Seller Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isSignIn) // Show seller name field only for sign-up
              TextField(
                onChanged: (value) => _sellerName = value.trim(),
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Seller Name'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_isSignIn ? 'Sign In' : 'Sign Up'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(_isSignIn ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}