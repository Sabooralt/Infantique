import 'package:infantique/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  String _message = '';

  FirebaseAuth _auth = FirebaseAuth.instance;
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
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.purple),
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: "Enter Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.purpleAccent,
                          )),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: "Enter Email",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: Icon(
                            Icons.email_sharp,
                            color: Colors.purpleAccent,
                          )),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: "Enter Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: Icon(
                            Icons.key,
                            color: Colors.purpleAccent,
                          ),
                          suffixIcon: Icon(Icons.remove_red_eye)),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: "Confirm Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: Icon(
                            Icons.key,
                            color: Colors.purpleAccent,
                          ),
                          suffixIcon: Icon(Icons.remove_red_eye)),
                    ),

                    SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: () async {
                        if (_passwordController.text !=
                            _confirmPasswordController.text) {
                          print('Passwords do not match');
                          return;
                        }
                        try {
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
                            'username': _nameController.text,
                            'email': _emailController.text,
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
                              builder: (context) => loginscreen(
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
                      },
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(
                        height:
                            10), // Add spacing between the button and the message
                    Text(
                      _message, // Display the message
                      style: TextStyle(
                        color: Colors.red, // Set the text color
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                                    builder: (context) => loginscreen(),
                                  ));
                            },
                            child: Text(
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
