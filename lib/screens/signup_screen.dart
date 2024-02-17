import 'package:infantique/controllers/user_controller.dart';
import 'package:infantique/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infantique/widgets/LoadingOverlay.dart';
import 'package:infantique/widgets/loadingManager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';

class signupscreen extends StatefulWidget {
  const signupscreen({Key? key}) : super(key: key);

  @override
  State<signupscreen> createState() => _signupscreenState();
}

class _signupscreenState extends State<signupscreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  GoogleSignIn _googleSignIn = GoogleSignIn();

  String _message = '';
  bool _isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo1.png",
                width: 200,
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.purple),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Enter Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.purpleAccent,
                          )),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Enter Email",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_sharp,
                            color: Colors.purpleAccent,
                          )),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Enter Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.key,
                            color: Colors.purpleAccent,
                          ),
                          suffixIcon: const Icon(Icons.remove_red_eye)),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Confirm Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.key,
                            color: Colors.purpleAccent,
                          ),
                          suffixIcon: const Icon(Icons.remove_red_eye)),
                    ),

                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          print('Passwords do not match');
                          return;
                        }
                        if (_nameController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          setState(() {
                            _message = 'Please fill in all fields';
                          });
                          return;
                        }
                        try {
                          LoadingManager().showLoading(context);
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          // Update the user's display name
                          await userCredential.user?.updateProfile(
                              displayName: _nameController.text);

                          // Save the user's information to Cloud Firestore
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userCredential.user?.uid)
                              .set({
                            'displayName': _nameController.text,
                            'email': _emailController.text,
                            'photoURL' : 'https://png.pngtree.com/png-vector/20190710/ourmid/pngtree-user-vector-avatar-png-image_1541962.jpg'
                            // Add other user-related information as needed
                          });

                          // Reload the user to get the updated information
                          await userCredential.user?.reload();

                          setState(() {
                            _message = 'Account created successfully!';
                          });
                          // After successful sign-up, navigate to the next page or perform any other actions
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const loginscreen(
                                  successMessage:
                                      'Account created successfully! Please Log In.'),
                            ),
                          );

                          print('user added');
                        } catch (e) {
                          if (e is FirebaseAuthException) {
                            String errorMessage = '';
                            switch (e.code) {
                              case 'weak-password':
                                errorMessage =
                                    'The password is too weak. Please choose a stronger password.';
                                break;
                              case 'email-already-in-use':
                                errorMessage =
                                    'The email address is already in use by another account.';
                                break;
                              default:
                                errorMessage =
                                    'An error occurred while signing up. Please try again later.';
                            }


                            // Set the error message
                            setState(() {
                              _message = errorMessage;
                            });

                            print('Error during sign up: $e');
                          }

                        }
                        finally {
                          setState(() {
                            _isLoading = false;
                          });

                          // Hide loading screen using LoadingManager
                          LoadingManager().hideLoading();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('-or-'),
                    SignInButton(
                      Buttons.google,
                      text: "Sign up with Google",
                      onPressed: () async {
                        try {
                          const CircularProgressIndicator();
                          await UserController().handleGoogleSignIn();
                        } catch (e) {
                          print('Error during Google Sign-In: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-In failed: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),


                    const SizedBox(
                        height:
                            10), // Add spacing between the button and the message
                    Text(
                      _message, // Display the message
                      style: const TextStyle(
                        color: Colors.red, // Set the text color
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an Account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const loginscreen(),
                                  ));
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
