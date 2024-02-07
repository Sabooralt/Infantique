import 'package:flutter/material.dart';
import 'package:infantique/screens/cart_screen.dart';
import 'package:infantique/screens/constants.dart';
import 'package:infantique/screens/search_screens/Search_Screen.dart';
import 'package:ionicons/ionicons.dart';

class Custom_Appbar extends StatelessWidget  implements PreferredSizeWidget{
  final String title;

  Custom_Appbar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Ionicons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Ionicons.search_outline),
    onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ),
            );
          },
    ),
    IconButton(
    icon: const Icon(Ionicons.cart_outline),
    onPressed: () {
      const CartScreen();
    },
    ),
    const SizedBox(width: kDefaultPaddin / 2)
    ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
