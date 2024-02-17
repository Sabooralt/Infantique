import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  final ValueChanged<String> onSectionSelected;

  const AdminSidebar({required this.onSectionSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            title: const Text('Users'),
            onTap: () => onSectionSelected('Users'),
          ),
          ListTile(
            title: const Text('Products'),
            onTap: () => onSectionSelected('Products'),
          ),
          ListTile(
            title: const Text('Orders'),
            onTap: () => onSectionSelected('Orders'),
          ),
          ListTile(
            title: const Text('Sellers'),
            onTap: () => onSectionSelected('Sellers'),
          ),
          ListTile(
            title: const Text('User Feedback'),
            onTap: () => onSectionSelected('User Feedback'),
          ),
        ],
      ),
    );
  }
}