import 'package:flutter/material.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/sellers/sellerWidgets/AddProduct.dart';
import 'package:infantique/widgets/Admin_Widgets/AdminSidebar.dart';
import 'package:infantique/widgets/Admin_Widgets/ProductsContent.dart';
import 'package:infantique/widgets/Admin_Widgets/UsersContent.dart';

class AdminPanelPage extends StatefulWidget {
  @override
  _AdminPanelPageState createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  String selectedSection = 'Users'; // Default selected section
  final ProductService productService = ProductService();


  Future<void> _refreshProducts() async {
    // Implement your logic to refresh the product list
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
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
      case 'Users':
        return UsersContent();
      case 'Products':
        return ProductsContent(
          productService: productService,
          refreshProducts: _refreshProducts,
        );
      case 'Add Product':
        return AddProduct();
      default:
        return Text('Select a section from the sidebar');
    }
  }
}