import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/admin_panel/AdminPanel.dart';
import 'package:infantique/screens/main_screen.dart';
import 'package:infantique/screens/sellers/SellersAuth.dart';
import 'package:infantique/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infantique/widgets/loadingManager.dart';
import 'package:infantique/controllers/user_controller.dart';
import 'package:infantique/admin_panel/product_crud.dart';
import 'package:iconly/iconly.dart';
import 'package:sign_in_button/sign_in_button.dart';


class loginscreen extends StatefulWidget {

  final String? successMessage; // Receive success message as a parameter
  const loginscreen({super.key, this.successMessage});

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
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if the signed-in user is a seller
      bool isSeller = await UserController.isUserSeller(userCredential.user!.uid);

      // If the user is a seller, show an error message and sign out
      if (isSeller) {
        await _auth.signOut();
        setState(() {
          _errorMessage = 'Seller accounts are not allowed here';
          _messageColor = Colors.red;
        });
      } else {
        // Proceed with navigation to the main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      // Handle sign-in errors (e.g., wrong password, user not found)
      setState(() {
        _errorMessage = 'Invalid email or password';
        _messageColor = Colors.red;
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
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Login",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.purple),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Enter Email",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.email_sharp,
                            color: Colors.purpleAccent,
                          )),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: Colors.grey),
                          labelText: "Enter Password",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(color: Colors.purpleAccent),
                          ),
                          prefixIcon: const Icon(
                            Icons.key,
                            color: Colors.purpleAccent,
                          ),
                          suffixIcon: const Icon(Icons.remove_red_eye)),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple,
                            ),
                          )),
                    ),
                    if (_errorMessage != null)
                      const SizedBox(height: 20), // Add spacing between the button and the message
                    Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: _messageColor,
                        )
                    ),


                    const SizedBox(height: 10,),

                    ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(55),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5,),
                    SignInButton(
                      Buttons.google,
                      text: "Sign In with Google",
                      onPressed: () async {
                        EasyLoading.show(status: 'loading...');
                        try {
                          await UserController().handleGoogleSignIn();
                          Navigator.of(context).pushReplacement(MaterialPageRoute(
                              builder: (context) => const MainScreen()));
                          EasyLoading.dismiss();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Google Sign-In failed: $e'),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an Account?",
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
                                    builder: (context) => const signupscreen(),
                                  ));
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 2,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminPanelPage(),
                      ));
                }, child: const Text("Admin Panel")

            ),
            const SizedBox(height: 5,),
            TextButton(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerAuthPage(),
                      ));
                }, child: const Text("Seller Login")

            ),
        ]
        ),

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
