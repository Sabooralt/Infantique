import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentTab;
  final Function(int) onTabSelected;

  const CustomBottomBar({
    Key? key,
    required this.currentTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ),
      child: BottomAppBar(
        elevation: 0,
        height: 70,
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => onTabSelected(2),
              icon: Icon(
                Ionicons.home_outline,
                color: currentTab == 2 ? Colors.blue : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () => onTabSelected(1),
              icon: Icon(
                Ionicons.heart_outline,
                color: currentTab == 1 ? Colors.blue : Colors.grey.shade400,
              ),
            ),
            IconButton(
              onPressed: () => onTabSelected(3),
              icon: Icon(
                Ionicons.cart_outline,
                color: currentTab == 3 ? Colors.blue : Colors.grey.shade400,
              ),
            ),
            // Add more icons or customize as needed
            IconButton(
              onPressed: () => onTabSelected(4),
              icon: Icon(
                Ionicons.person_outline,
                color: currentTab == 4 ? Colors.blue : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
