import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infantique/screens/home_screen.dart';
import 'package:infantique/screens/main_screen.dart';
import 'package:infantique/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
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