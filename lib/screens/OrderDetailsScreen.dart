import 'package:cloud_firestore/cloud_firestore.dart' as FireStore;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/models/orders_model.dart' as MyOrder;

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;

  OrderDetailsScreen({required this.orderId});

  @override
  Widget build(BuildContext context) {

          return Scaffold(
            appBar: AppBar(
              title: Text('Order Details'),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: '),
                Text('User ID: '),
                Text('Delivery Address: '),
                // Add more fields as needed
                // Fetch and display products
                buildProductList(orderId),
              ],
            ),
          );
        }

  Widget buildProductList(String orderId) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('orders').doc(orderId).collection('items').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          var items = snapshot.data!.docs;

          // Convert each item document into a Product object
          List<Product> products = items.map((item) {
            var itemData = item.data() as Map<String, dynamic>;

            return Product(
              id: itemData['productId'],
              quantity: itemData['quantity'], title: '', images: [], description: '', category: '', reviews: [], price: 0, sellerId: '',averageRating: 0.0
              // Add other product details as needed
            );
          }).toList();

          // Display the list of products
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Products:'),
              for (Product product in products)
                ListTile(
                  title: Text('Product ID: ${product.id}'),
                  subtitle: Text('Quantity: ${product.quantity}'),
                  // Add more fields as needed
                ),
            ],
          );
        }
      },
    );
  }
}
