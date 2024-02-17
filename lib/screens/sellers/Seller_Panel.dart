import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:infantique/screens/sellers/sellerWidgets/sellerPanelSidebar.dart';
import 'package:infantique/screens/sellers/sellerWidgets/soldProducts.dart';
import 'package:infantique/screens/sellers/sellerWidgets/viewRatings.dart';
import 'package:infantique/screens/sellers/sellerWidgets/yourProducts.dart';
import 'package:infantique/screens/sellers/sellerWidgets/yourReviews.dart';

import 'sellerWidgets/AddProduct.dart';

class SellerPanel extends StatefulWidget {
  final User user;

  const SellerPanel({super.key, required this.user});

  @override
  _SellerPanelState createState() => _SellerPanelState();
}

class _SellerPanelState extends State<SellerPanel> {
  late String sellerName = 'Loading...';
  late String selectedSection = 'Your Products';

  @override
  void initState() {
    super.initState();
    fetchSellerInformation();
  }

  Future<void> fetchSellerInformation() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.user.uid)
          .get();

      if (snapshot.exists) {
        sellerName = snapshot['name'];
      } else {
        // Handle the case when the document does not exist
        print('Seller document does not exist for user ${widget.user.uid}');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching seller information: $e');
      // Handle the error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Panel'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: RichText(
              text: TextSpan(
                text: 'Logged in as ',
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Adjust the color as needed
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: sellerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black, // Adjust the color as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: SellerSidebar(
        sellerName: sellerName ?? 'Loading...',
        selectedSection: selectedSection,
        onSectionSelected: (section) {
          setState(() {
            selectedSection = section;
          });
          Navigator.pop(context); // Close the drawer
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: getContent(selectedSection),
        ),
      ),
    );
  }



  Widget getContent(String section) {
    switch (section) {
      case 'Your Products':
        return YourProductsWidget();
      case 'Add Product':
        return const AddProduct();
      case 'View Ratings':
        return ViewRatingsWidget();
      case 'Sold Products':
        return const SoldProductsWidget();
      case 'Reviews':
        return const ReviewsWidget();
      default:
        return const Text('Select a section from the sidebar');
    }
  }
}

