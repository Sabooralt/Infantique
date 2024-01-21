import 'package:infantique/screens/main_screen.dart';
import 'package:infantique/screens//signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infantique/widgets/LoadingOverlay.dart';
import 'package:infantique/widgets/loadingManager.dart';
import 'constants.dart';
import 'package:infantique/admin_panel/product_crud.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class loginscreen extends StatefulWidget {

  final String? successMessage; // Receive success message as a parameter
  const loginscreen({Key? key, this.successMessage}) : super(key: key);

  @override
  State<loginscreen> createState() => _loginscreenState();
}

class _loginscreenState extends State<loginscreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  Color _messageColor = Colors.red;

  @override
  void initState() {
  super.initState();
  // Set the success message when the login page is initialized
  _errorMessage = widget.successMessage ?? ''; // Provide a default value
  // Set the color based on the success message
  _messageColor = _errorMessage == 'Account created successfully! Please Log In.' ? Colors.green : Colors.red;
}

bool _isLoading = false;

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
        _messageColor = Colors.red;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {

      // Sign in the user with email and password
      LoadingManager().showLoading(context);
      // Simulate asynchronous sign-in process

      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // If successful, navigate to the main screen or perform other actions
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } catch (e) {
      // Handle sign-in errors (e.g., wrong password, user not found)
      print('Error during sign in: $e');
      setState(() {
        _errorMessage = 'Invalid email or password';
        _messageColor =  Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Hide loading screen using LoadingManager
      LoadingManager().hideLoading();
    }
  }




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
                  "Login",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.purple),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
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
                    SizedBox(height: 15),
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
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                          )),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(55),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    if (_errorMessage != null)
                      SizedBox(
                          height:
                              10), // Add spacing between the button and the message
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                           color: _messageColor,
                            )
                    ),

                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an Account?",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(onPressed: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminPanel(),
                              ));
                        }, child: Text("Admin Panel")

                        ),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => signupscreen(),
                                  ));
                            },
                            child: Text(
                              "Sign Up",
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
