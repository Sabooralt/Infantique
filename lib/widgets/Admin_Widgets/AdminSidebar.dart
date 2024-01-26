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
            title: Text('Users'),
            onTap: () => onSectionSelected('Users'),
          ),
          ListTile(
            title: Text('Products'),
            onTap: () => onSectionSelected('Products'),
          ),
          ListTile(
            title: Text('Add Product'),
            onTap: () => onSectionSelected('Add Product'),
          ),
          ListTile(
            title: Text('Sellers'),
            onTap: () => onSectionSelected('Sellers'),
          ),
          ListTile(
            title: Text('User Feedback'),
            onTap: () => onSectionSelected('User Feedback'),
          ),
        ],
      ),
    );
  }
}