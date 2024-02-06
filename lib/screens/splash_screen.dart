import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infantique/screens//login_screen.dart';

class spscreen extends StatefulWidget {
  const spscreen({super.key});

  @override
  State<spscreen> createState() => _spscreenState();
}

class _spscreenState extends State<spscreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const loginscreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple, // Set your desired background color
      body: Center(
        child: AnimatedTextLogo(),
      ),
    );
  }
}

class AnimatedTextLogo extends StatefulWidget {
  @override
  _AnimatedTextLogoState createState() => _AnimatedTextLogoState();
}

class _AnimatedTextLogoState extends State<AnimatedTextLogo> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, double opacity, child) {
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(seconds: 1),
          child: const TextLogo(),
        );
      },
    );
  }
}

class TextLogo extends StatelessWidget {
  const TextLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Set the background color to transparent
      child: const Center(
        child: Text(
          "infantique.",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 34,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}