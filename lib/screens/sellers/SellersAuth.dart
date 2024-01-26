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

  Future<void> _submitForm() async {
    try {
      User user = await _authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Create a Seller object or fetch additional seller information


      // After successful sign-in or sign-up, navigate to the SellerPanel
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SellerPanel(user: user)),
      );

      // Show success message in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign In successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors, show a snackbar, etc.
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
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