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

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
        await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        // Save user data to Firestore and authentication table
        if (user != null) {
          await _saveUserDataToFirestore(user);
        }

        print('Google Sign-In success: ${user?.displayName}');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // Handle the error as needed
    }
  }

  Future<void> _saveUserDataToFirestore(User user) async {
    // Get a reference to the users collection in Firestore
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    // Check if the user already exists in Firestore
    DocumentSnapshot userSnapshot =
    await usersCollection.doc(user.uid).get();

    if (!userSnapshot.exists) {
      // If the user doesn't exist, add them to Firestore
      await usersCollection.doc(user.uid).set({
        'username': user.displayName,
        'email': user.email,
        // Add other user-related information as needed
      });
    } else {
      // If the user already exists, update their information
      await usersCollection.doc(user.uid).update({
        'username': user.displayName,
        'email': user.email,
        // Add other user-related information as needed
      });
    }

    // Save user data to the authentication table
    await _auth.currentUser?.updateProfile(displayName: user.displayName);

    // You can add additional fields to the authentication table if needed
    // For example, you might want to store user metadata in Firebase Authentication
    // Note: This is optional and depends on your application's requirements
    await _auth.currentUser?.reload();
  }




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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: "Enter Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
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
                            borderRadius: BorderRadius.circular(20.0),
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
                            borderRadius: BorderRadius.circular(20.0),
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
                            borderRadius: BorderRadius.circular(20.0),
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
                        finally {
                          setState(() {
                            _isLoading = false;
                          });

                          // Hide loading screen using LoadingManager
                          LoadingManager().hideLoading();
                        }
                      },

                      child: Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.normal),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('-or-'),
                    SignInButton(
                      Buttons.google,
                      text: "Sign up with Google",
                      onPressed: () async {
                        try {
                          await _handleGoogleSignIn();
                        } catch (e) {
                          print('Error during Google Sign-In: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-In failed: $e'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
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
