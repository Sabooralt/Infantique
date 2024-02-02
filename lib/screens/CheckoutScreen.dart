// CheckoutScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/controllers/user_settings_controller.dart';
import 'package:infantique/models/cart_item.dart';
import 'package:infantique/screens/UserProfile.dart';
import 'package:infantique/screens/main_screen.dart';
import 'package:infantique/screens/widgets/check_out_box.dart';
import 'package:infantique/screens/widgets/product_widgets/CheckoutProductCard.dart';
import 'package:provider/provider.dart';
import 'package:infantique/models/cart_provider.dart';
import 'package:infantique/models/product.dart';

import '../constants.dart';

class CheckoutScreen extends StatefulWidget {
  final Product? singleProduct;
  String deliveryAddress = '';
  List<Map<String, dynamic>> paymentMethods = [];
  List<int> quantities = [];

  // Constructor that takes a Product parameter
  CheckoutScreen({this.singleProduct});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Future<Map<String, dynamic>> fetchUserDetails() async {
    try {
      print('Fetching user details...');

      // Get the current user's ID from Firebase Authentication
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Check if the user is authenticated
      if (userId != null) {
        print('User ID: $userId');

        // Reference to the "users" collection
        CollectionReference usersCollection =
            FirebaseFirestore.instance.collection('users');

        // Reference to the user's document
        DocumentReference userDocument = usersCollection.doc(userId);

        // Reference to the "delivery_addresses" subcollection
        CollectionReference deliveryAddressesCollection =
            userDocument.collection('delivery_addresses');

        // Reference to the "payment_methods" subcollection
        CollectionReference paymentMethodsCollection =
            userDocument.collection('payment_methods');

        // Fetch the first delivery address
        QuerySnapshot deliveryAddressesSnapshot =
            await deliveryAddressesCollection.limit(1).get();
        Map<String, String>? deliveryAddress;

        if (deliveryAddressesSnapshot.docs.isNotEmpty) {
          DocumentSnapshot deliveryAddressSnapshot =
              deliveryAddressesSnapshot.docs.first;
          String name = deliveryAddressSnapshot['name'] ?? '';
          String address = deliveryAddressSnapshot['address'] ?? '';
          deliveryAddress = {'name': name, 'address': address};
        }

        // Fetch all payment methods
        QuerySnapshot paymentMethodsSnapshot =
            await paymentMethodsCollection.get();
        List<Map<String, String>> paymentMethods =
            paymentMethodsSnapshot.docs.map((DocumentSnapshot methodSnapshot) {
          String cardNumber = methodSnapshot['card_info'] ?? '';
          return {'cardNumber': cardNumber};
        }).toList();

        // Return user details as a map
        Map<String, dynamic> userDetails = {
          'deliveryAddress': deliveryAddress,
          'paymentMethods': paymentMethods,
        };
        print('User details: $userDetails');

        return userDetails;
      } else {
        // User is not authenticated
        print('User is not authenticated.');
        throw Exception('User is not authenticated.');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      // Handle the error as needed
      throw Exception('Error fetching user details. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.singleProduct == null)
              // 2. Fetch Cart Items
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  List<CartItem> cartItems = cartProvider.cartItems;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        'Products in Cart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      // Use the ProductCard widget for each product in the cart

                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return CheckoutProductCard(item: cartItems[index]);
                        },
                      ),

                      // Add your payment method widget here
                    ],
                  );
                },
              )
            else
              // Display information about the single product
              ListTile(
                title: Text(widget.singleProduct!.title),

                // Add other details as needed
              ),
            // 4. Delivery Address
            const SizedBox(height: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  margin: const EdgeInsets.only(top: 10),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: fetchUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        Map<String, dynamic> userDetails = snapshot.data!;
                        Map<String, String>? deliveryAddress =
                            userDetails['deliveryAddress'];
                        List<Map<String, String>> paymentMethods =
                            userDetails['paymentMethods'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (deliveryAddress != null)
                              InkWell(
                                onTap: () {
                                  // Handle the onTap event if needed
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.purple, width: 2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${deliveryAddress['name']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Address: ${deliveryAddress['address']}',
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Text('No delivery address available.'),
                            SizedBox(height: 20),
                            Text(
                              'Payment Methods',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            if (paymentMethods.isNotEmpty)
                              Column(
                                children: paymentMethods.map((paymentMethod) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Card Number: ${paymentMethod['cardNumber']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              )
                            else
                              Text('No payment methods available.'),
                          ],
                        );
                      } else {
                        return Text('No user details available.');
                      }
                    },
                  ),
                ),

                // Add your payment method widget here

                const SizedBox(height: 20.0),
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    List<CartItem> cartItems = cartProvider.cartItems;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.purple, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          CheckOutBox(items: cartItems),
                        ],
                      ),
                    );
                  },
                ),

                // Add your order summary widget here
              ],
            ),
          ],
        ),
      ),


      persistentFooterButtons: [
        Container(
          alignment: Alignment.center,
          child:  Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          List<CartItem> cartItems = cartProvider.cartItems;
          final CheckOutBox checkOutBox = CheckOutBox(items: cartProvider.cartItems);
          return ElevatedButton(
            onPressed: () async {
              try{
                EasyLoading.instance
                  ..displayDuration =const Duration(milliseconds: 2000)
                  ..maskType = EasyLoadingMaskType.custom //This was missing in earlier code
                  ..backgroundColor = Colors.black
                  ..indicatorColor = Colors.white
                  ..textColor = Colors.white
                  ..maskColor = Colors.black54
                  ..dismissOnTap = false;
                EasyLoading.showSuccess('Order Placed Successfully!');

                // Wait for a short duration to display the success message
                await Future.delayed(Duration(seconds: 2));

                Map<String, dynamic> userDetails = await fetchUserDetails();
                String userDeliveryAddress = userDetails['deliveryAddress']['address'] ?? '';
                // Adjust the key based on your data structure
                Map<String, dynamic> orderDetails = checkOutBox.getOrderDetails();

                await cartProvider.placeOrder(userDeliveryAddress,orderDetails);
                // Hide the loading indicator
                EasyLoading.dismiss();


                // Call the placeOrder method in your CartProvider

                // Navigate to the main screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(),
                  ),
                );
              }catch(e){
                EasyLoading.showError('Error');
              }

            },
            child: const Text(
              'Place Order',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kprimaryColor,
              minimumSize: const Size(double.infinity, 55),
              // Adjust the width and height as needed
            ),
          );
        }
        )
        ),
      ],
    );
  }
}
