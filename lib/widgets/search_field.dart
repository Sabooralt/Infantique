import 'package:flutter/material.dart';
import 'package:infantique/screens/search_screens/Search_Screen.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/constants.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchScreen()),
        );
      },
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: kcontentColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(6.0, 7.0),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 5,
        ),
        child: Row(
          children: [
            const Icon(
              Ionicons.search,
              color: Colors.grey,
            ),
            const SizedBox(width: 10),
            const Flexible(
              flex: 4,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              height: 25,
              width: 1.5,
              color: Colors.grey,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Ionicons.options_outline,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
