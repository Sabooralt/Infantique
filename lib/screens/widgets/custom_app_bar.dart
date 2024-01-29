import 'package:flutter/material.dart';
import 'package:infantique/screens/constants.dart';
import 'package:infantique/screens/search_screens/Search_Screen.dart';
import 'package:ionicons/ionicons.dart';

class Custom_Appbar extends StatelessWidget  implements PreferredSizeWidget{
  const Custom_Appbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
      SearchScreen();
    },
    ),
    IconButton(
    icon: const Icon(Ionicons.cart_outline),
    onPressed: () {
    },
    ),
    SizedBox(width: kDefaultPaddin / 2)
    ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
