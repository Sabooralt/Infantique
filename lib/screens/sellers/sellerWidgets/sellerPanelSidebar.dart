import 'package:flutter/material.dart';

class SellerSidebar extends StatelessWidget {
  late String sellerName = 'Loading...';
  final String selectedSection;
  final Function(String) onSectionSelected;

  SellerSidebar({
    required this.sellerName,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(sellerName ?? 'Loading...'),
            accountEmail: null, // You can add the seller's email if needed
          ),
          ListTile(
            title: const Text('Your Products'),
            onTap: () => onSectionSelected('Your Products'),
            selected: selectedSection == 'Your Products',
          ),
          ListTile(
            title: const Text('Add Product'),
            onTap: () => onSectionSelected('Add Product'),
            selected: selectedSection == 'Add Product',
          ),
          ListTile(
            title: const Text('View Ratings'),
            onTap: () => onSectionSelected('View Ratings'),
            selected: selectedSection == 'View Ratings',
          ),
          ListTile(
            title: const Text('Sold Products'),
            onTap: () => onSectionSelected('Sold Products'),
            selected: selectedSection == 'Sold Products',
          ),
          ListTile(
            title: const Text('Reviews'),
            onTap: () => onSectionSelected('Reviews'),
            selected: selectedSection == 'Reviews',
          ),
        ],
      ),
    );
  }
}