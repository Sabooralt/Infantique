import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infantique/screens/home_screen.dart';
import 'package:infantique/screens/login_screen.dart';
import 'package:infantique/screens/main_screen.dart';
import 'package:infantique/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.mulishTextTheme(),
      ),
      home: const spscreen(),
    );
  }

}
class Authentication extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(

        stream: _auth.authStateChanges(),

        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data as User?;

            return user == null ? loginscreen() : MyApp();
          }
          return  spscreen();
        }
    );
  }
}
