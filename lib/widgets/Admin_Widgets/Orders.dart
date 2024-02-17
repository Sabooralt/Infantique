import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/models/orders_model.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/models/userDetails.dart';
import 'package:ionicons/ionicons.dart';

class OrdersScreen extends StatelessWidget {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrdersScreen({super.key});

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      CollectionReference ordersCollection = _firestore.collection('orders');

      // Reference to the specific order document
      DocumentReference orderDocRef = ordersCollection.doc(orderId);

      // Update the status field
      await orderDocRef.update({'status': newStatus});

    } catch (e) {
      throw Exception('Error updating order status. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.stretch,
     children: [
       const Padding(
         padding: EdgeInsets.all(16.0),
         child: Text(
           'Orders',
           style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
         ),
       ),
       Expanded(
         child: FutureBuilder<List<MyOrder>>(
                 future: _orderService.fetchAllOrdersWithDetails(),
             builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
             } else if (snapshot.hasError) {
             return Center(child: Text('Error fetching orders: ${snapshot.error}'));
             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
             return const Center(child: Text('No orders available.'));
             } else {
             return ListView.separated(
             itemCount: snapshot.data!.length,
               separatorBuilder: (BuildContext context, int index) {
                 return const SizedBox(height: 16.0); // Adjust the height as needed
               },
             itemBuilder: (context, index) {
             MyOrder order = snapshot.data![index];
             return Padding(
               padding: const EdgeInsets.all(8.0),
               child: Container(
                 decoration: BoxDecoration(
                   border: Border.all(
                     color: Colors.black,  // Set the border color
                     width: 2.0,           // Set the border width
                   ),
                   borderRadius: const BorderRadius.all(Radius.circular(8.0)),  // Set border radius for rounded corners
                 ),
                 child: Card(
                   clipBehavior: Clip.antiAliasWithSaveLayer,
                   color: Colors.white,
                 child: Column(
                 children: [
                 ListTile(
                 title: Text('Order Number: ${order.orderNumber}'),
                 subtitle: Text('Status: ${order.status}'),
                   leading:  IconButton(
                     icon: const Icon(Ionicons.create_outline),
                     onPressed: () {
                    _showUpdateStatusBottomSheet(context, order);
                     },
                   ),
                 ),
                 const Divider(),
                 const Text('Bought by:',
                   style: TextStyle(
                     fontSize: 20,
                   ),
                 ),
                   const SizedBox(height: 10,),
                 FutureBuilder<UserDetails>(
                 future: fetchUserDetails(order.userId),
                 builder: (context, userSnapshot) {
                   if (userSnapshot.connectionState == ConnectionState.waiting) {
                     return const Center(child: CircularProgressIndicator());
                   } else if (userSnapshot.hasError) {
                     return Center(
                      child: Text('Error fetching user details: ${userSnapshot.error}'));
                   } else {
                     UserDetails user = userSnapshot.data!;
                     return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text('Name: ${user.username}'),
                      Text('Email: ${user.userEmail}'),


                      // Add other user details as needed
                    ],
                     );
                   }
                 },
                 ),
                   const Divider(),

                   const Text('Order Details:',
                     style: TextStyle(
                    fontSize: 20,
                     ),
                   ),
                   const SizedBox(height: 10,),
                         Text('Delivery Charges: ${order.orderDetails['deliveryCharges']}'),
                         Text('Sub Total: ${order.orderDetails['subtotal']}'),
                         Text('Total With Delivery: ${order.orderDetails['totalWithDelivery']}'),
                         const Divider(),
                   const Text('Product Details',
                     style: TextStyle(
                    fontSize: 20,
                     ),
                   ),

                         const SizedBox(height: 20,),
                         FutureBuilder<List<Product>>(
                           future: _productService.getProductsForOrder(order.orderId),
                           builder: (context, productsSnapshot) {
                             if (productsSnapshot.connectionState == ConnectionState.waiting) {
                               return const Center(child: CircularProgressIndicator());
                             } else if (productsSnapshot.hasError) {
                               return Center(child: Text('Error fetching product details: ${productsSnapshot.error}'));
                             } else if (!productsSnapshot.hasData || productsSnapshot.data!.isEmpty) {
                               return const Center(child: Text('No product details available.'));
                             } else {
                               return Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: productsSnapshot.data!.map((product) {
                                    return Container(
                                     padding: const EdgeInsets.all(8),
                                     margin: const EdgeInsets.symmetric(vertical: 8),
                                     decoration: BoxDecoration(
                                       color: Colors.white60,
                                       borderRadius: BorderRadius.circular(8.0),
                                       boxShadow: [
                                         BoxShadow(
                                           color: Colors.grey.withOpacity(0.2),
                                           spreadRadius: 2,
                                           blurRadius: 4,
                                           offset: const Offset(0, 2),
                                         ),
                                       ],
                                     ),
                                     child: Row(
                                       children: [
                                         Container(
                                           height: 80,
                                           width: 80,
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(8),
                                             image: DecorationImage(
                                               image: NetworkImage(product.images[0]),
                                               fit: BoxFit.cover,
                                             ),
                                           ),
                                         ),
                                         const SizedBox(width: 12),
                                         Expanded(
                                           child: Column(
                                             crossAxisAlignment: CrossAxisAlignment.start,
                                             children: [
                                               Text(
                                                 product.title,
                                                 style: const TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 16,
                                                 ),
                                               ),
                                               const SizedBox(height: 8),
                                               Text(
                                                 'Rs.${product.price.toString()}',
                                                 style: const TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 14,
                                                   color: Colors.grey,
                                                 ),
                                               ),
                                               Text(
                                                 'Qt.(${order.quantity.toString()})',
                                                 style: const TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 14,
                                                   color: Colors.grey,
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ),
                                       ],
                                     ),
                                   );
                                 }).toList(),
                               );
                             }
                           },
                         ),

                       ],
                     ),
                   ),
               ),
             );
             },
           );
         }
                 },
               ),
       ),
     ],
   );

  }
  void _showUpdateStatusBottomSheet(BuildContext context, MyOrder order) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Order Number: ${order.orderNumber}'),
              subtitle: Text('Current Status: ${order.status}'),
            ),
            ListTile(
              title: const Text('Delivered'),
              onTap: () {
                _updateStatusAndClose(context, order, 'Delivered');
              },
            ),
            ListTile(
              title: const Text('Processing'),
              onTap: () {
                _updateStatusAndClose(context, order, 'Processing');
              },
            ),
            ListTile(
              title: const Text('Shipped'),
              onTap: () {
                _updateStatusAndClose(context, order, 'Shipped');
              },
            ),
          ],
        );
      },
    );
  }

  void _updateStatusAndClose(BuildContext context,  MyOrder order, String newStatus) {
    updateOrderStatus(order.orderId, newStatus);

    Navigator.of(context).pop();
    EasyLoading.showToast('Status Updated to "$newStatus" for Order: ${order.orderNumber}');
    // Close the bottom sheet
  }
}

