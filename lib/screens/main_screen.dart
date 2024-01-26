import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infantique/controllers/user_controller.dart';
import 'package:infantique/screens/UserProfile.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/screens/cart_screen.dart';
import 'package:infantique/screens/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentTab = 2;
  List screens = [
    const Scaffold(),
    const Scaffold(),
    const HomeScreen(),
    const CartScreen(),
    UserProfile(),
    const Scaffold(),
  ];

  Widget buildProfileIcon() {
    if (UserController.user != null) {
      if (UserController.user!.providerData.isNotEmpty &&
          UserController.user!.providerData[0].providerId == 'google.com') {
        // User signed in with Google, use Google profile picture
        return InkWell(
          onTap: () => setState(() {
            currentTab = 4;
          }),
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 18,
                foregroundImage: NetworkImage(FirebaseAuth.instance.currentUser?.photoURL ?? ''),
              ),
            ),
          ),
        );
      } else {
        // User signed in manually, use custom profile picture if available
        if (UserController.user!.photoURL != null && UserController.user!.photoURL!.isNotEmpty) {
          return InkWell(
            onTap: () => setState(() {
              currentTab = 4;
            }),
            child: Container(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 18,
                  foregroundImage: NetworkImage(UserController.user!.photoURL!),
                ),
              ),
            ),
          );
        } else {
          // User signed in manually without a custom profile picture
          return IconButton(
            onPressed: () => setState(() {
              currentTab = 4;
            }),
            icon: Icon(
              Ionicons.person_outline,
              color: currentTab == 4 ? kprimaryColor : Colors.grey.shade400,
            ),
          );
        }
      }
    } else {
      // User is not signed in
      return IconButton(
        onPressed: () => setState(() {
          currentTab = 4;
        }),
        icon: Icon(
          Ionicons.person_outline,
          color: currentTab == 4 ? kprimaryColor : Colors.grey.shade400,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentTab = 2;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: kprimaryColor,
        child: const Icon(
          Iconsax.home,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        height: 70,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 5,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() {
                currentTab = 0;
              }),
              icon: Icon(
                Ionicons.grid_outline,
                color: currentTab == 0 ? kprimaryColor : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentTab = 1;
              }),
              icon: Icon(
                Ionicons.heart_outline,
                color: currentTab == 1 ? kprimaryColor : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                currentTab = 3;
              }),
              icon: Icon(
                Ionicons.cart_outline,
                color: currentTab == 3 ? kprimaryColor : Colors.grey.shade400,
              ),
            ),
            buildProfileIcon(),

          ],
        ),
      ),
      body: screens[currentTab],
    );
  }
}
