import 'package:flutter/material.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/widgets/Admin_Widgets/AdminSidebar.dart';
import 'package:infantique/widgets/Admin_Widgets/Orders.dart';
import 'package:infantique/widgets/Admin_Widgets/ProductsContent.dart';
import 'package:infantique/widgets/Admin_Widgets/Sellers.dart';
import 'package:infantique/widgets/Admin_Widgets/UserSupport.dart';
import 'package:infantique/widgets/Admin_Widgets/UsersContent.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  String selectedSection = 'Users'; // Default selected section
  final ProductService productService = ProductService();
  String appBarTitle = 'Admin Panel';


  Future<void> _refreshProducts() async {
    // Implement your logic to refresh the product list
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      drawer: AdminSidebar(
        onSectionSelected: (section) {
          setState(() {
            selectedSection = section;
          });
          Navigator.pop(context); // Close the drawer
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding to all sides
        child: Center(
          child: getContent(selectedSection),
        ),
      ),
    );
  }

  Widget getContent(String section) {
    switch (section) {
      case 'Orders':
        appBarTitle = 'Orders';
        return OrdersScreen();
      case 'Sellers':
        appBarTitle = 'Sellers';
        return const Sellers();
      case 'Users':
        appBarTitle = 'Users';
        return const UsersContent();
      case 'Products':
        appBarTitle = 'Products';
        return ProductsContent(
          productService: productService,
          refreshProducts: _refreshProducts,
        );
      case 'User Feedback':
        appBarTitle = 'User Feedback';
        return const AdminUserSupport();
      default:
        appBarTitle = 'Admin Panel';
        return const Text('Select a section from the sidebar');
    }
  }
}