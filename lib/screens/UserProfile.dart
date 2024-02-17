import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/screens/user/EditUserProfile.dart';
import 'package:infantique/controllers/user_controller.dart';
import 'package:infantique/controllers/user_settings_controller.dart';
import 'package:infantique/models/orders_model.dart';
import 'package:infantique/screens/OrderDetailsScreen.dart';
import 'package:infantique/screens/login_screen.dart';
import 'package:infantique/screens/user/change_password.dart';
import 'package:infantique/screens/user/email_verification.dart';
import 'package:infantique/screens/widgets/SupportFloatingActionButton.dart';
import 'package:ionicons/ionicons.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<DeliveryAddress> deliveryAddresses = [];
  List<Map<String, dynamic>> paymentMethods = [];
  final FirebaseAuth auth = FirebaseAuth.instance;
  OrderService orderService = OrderService();
  User? user = FirebaseAuth.instance.currentUser;

  String getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;
    } else {
      // Handle the case where the user is not logged in
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch delivery addresses when the screen initializes
    _fetchUserDeliveryAddresses();
    _fetchUserPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Addresses Section
            const SectionTitle('Delivery Addresses'),

            ListTile(
              title: const Text('Add Delivery Address'),
              leading: const Icon(Icons.add),
              onTap: () {
                User_Settings_Controller.showAddAddressDialog(context,
                    (newAddress) async {
                  // Add the new address to Firestore
                  await _addAddressToFirestore(newAddress);

                  // Update the state to reflect the new address
                  setState(() {
                    deliveryAddresses.add(newAddress);
                  });
                });
              },
            ),
            Column(
              children: [
                for (var deliveryAddress in deliveryAddresses)
                  DeliveryAddressCard(
                    name: deliveryAddress.name,
                    address: deliveryAddress.address,
                    documentId: deliveryAddress.documentId,
                    onDelete: (deletedId) {
                      setState(() {
                        paymentMethods.removeWhere(
                            (method) => method['documentId'] == deletedId);
                      });
                    },
                  ),
              ],
            ),
          const SectionTitle('Orders'),
    Column(children: [
              FutureBuilder<List<MyOrder>>(
                  future: fetchOrders(),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show loading indicator while fetching orders
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      // Handle error if fetching orders fails
                      return Center(
                          child:
                              Text('Error fetching orders: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Show a message if there are no orders
                      return const Center(child: Text('No orders available.'));
                    } else {
                      // Create a list of OrderCard widgets
                      List<Widget> orderCards = snapshot.data!.map((order) {

                        return OrderCard(
                          orderNumber: order.orderNumber,
                          orderId: order.orderId,
                          status: order.status,

                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsScreen(


                                    orderId: order.orderId,
                                  orderNumber: order.orderNumber,



                                ),
                              ),
                            );
                          },
                        );
                      }).toList();
                     print('Orders Fetched orderId');
                      // Return a ListView with OrderCard widgets
                      return Column(

                        children: orderCards,
                      );
                    }
                  })
            ]),


            // Orders Section

            // Profile Settings Section
            const SectionTitle('Profile Settings'),

            ListTile(
              title: const Text('Edit Profile'),
              leading: const Icon(Ionicons.person,color: Colors.black,),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ));
              },
            ),
            ListTile(
              title: const Text('Change Password'),
              leading: const Icon(Ionicons.lock_closed,
              color: Colors.black,),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ));
              },
            ),
            ...[
          if (user?.emailVerified == false)
        ListTile(
        title: const Text('Verify Email'),
    leading: const Icon(Ionicons.mail,
    color: Colors.black,),
    onTap: () {
    Navigator.push(
    context,
    MaterialPageRoute(
    builder: (context) => EmailVerificationScreen(),
    ),
    );
    },
    ),
          ],




            // Payment Methods Section
            const SectionTitle('Payment Methods'),
            ListTile(
              title: const Text('Add Payment Method'),
              leading: const Icon(Icons.add),
              onTap: () {
                PaymentController.showAddPaymentMethodDialog(context,
                    (newPaymentMethod) async {
                  // Add the new payment method to Firestore
                  await _addPaymentToFirestore(newPaymentMethod);

                  // Update the state to reflect the new payment method
                  setState(() {
                    paymentMethods.add({
                      'cardInfo': newPaymentMethod,
                      'documentId': newPaymentMethod,
                    });
                  });

                  // Optionally, you can display a SnackBar or perform other UI updates
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment method added successfully!'),
                    ),
                  );
                });
              },
            ),

            Column(
              children: [
                for (var paymentMethod in paymentMethods)
                  PaymentMethodCard(
                    cardInfo: paymentMethod['cardInfo'],
                    documentId: paymentMethod['documentId'],
                    onDelete: (deletedId) {
                      setState(() {
                        paymentMethods.removeWhere(
                            (method) => method['documentId'] == deletedId);
                      });
                    },
                  ),
              ],
            ),

            // Logout Section
            const SectionTitle('Logout'),
            ListTile(
              title: const Text('Logout'),
              leading: const Icon(Icons.exit_to_app),
              onTap: () async {
                // Show loading indicator with "Logging Out..." text
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text('Logging Out...'),
                        ],
                      ),
                    );
                  },
                );

                try {
                  // Delay for 2 seconds
                  await Future.delayed(const Duration(seconds: 2));

                  // Sign out
                  await UserController.signOut();

                  // Close the loading indicator
                  Navigator.pop(context);

                  // Navigate to login screen
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const loginscreen(),
                  ));
                } catch (e) {
                  // Handle errors if necessary
                  print('Error: $e');
                  Navigator.pop(context); // Close the loading indicator
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonWidget(),
    );

  }

  Future<List<MyOrder>> fetchOrders() async {
    String userId = getCurrentUserId();
    List<MyOrder> orders = await orderService.fetchOrders(userId);
    return orders;
  }

  Future<void> _fetchUserDeliveryAddresses() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('delivery_addresses')
          .get();

      List<DeliveryAddress> addresses = snapshot.docs.map((doc) {
        return DeliveryAddress(
          name: doc['name'],
          address: doc['address'],
          documentId: doc.id, // Include the document ID
        );
      }).toList();

      setState(() {
        deliveryAddresses = addresses;
      });

      print('Delivery addresses fetched successfully!');
    } catch (e) {
      print('Error fetching user delivery addresses: $e');
    }
  }

  //Add Delivery Address to firebase
  Future<String> _addAddressToFirestore(DeliveryAddress address) async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('delivery_addresses')
          .add({
        'name': address.name,
        'address': address.address,
      });

      String documentId = docRef.id;

      print('Delivery address added to Firestore with ID: $documentId');

      return documentId;
    } catch (e) {
      print('Error adding delivery address to Firestore: $e');
      return ''; // Return an empty string or handle the error accordingly
    }
  }

  //Add Payment Methods To Firebase

  // Fetch Payment Methods from Firestore
  Future<void> _fetchUserPaymentMethods() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('payment_methods')
          .get();

      List<Map<String, dynamic>> methods = snapshot.docs.map((doc) {
        return {
          'cardInfo': doc['card_info'],
          'documentId': doc.id,
        };
      }).toList();

      setState(() {
        paymentMethods = methods;
      });

      print('Payment methods fetched successfully!');
    } catch (e) {
      print('Error fetching user payment methods: $e');
    }
  }

  Future<void> _addPaymentToFirestore(String cardInfo) async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('payment_methods')
          .add({
        'card_info': cardInfo,
      });

      print('Payment method added to Firestore!');
    } catch (e) {
      print('Error adding payment method to Firestore: $e');
    }
  }
}



class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DeliveryAddressCard extends StatelessWidget {
  final String name;
  final String address;
  final String documentId;
  final Function(String) onDelete;

  const DeliveryAddressCard(
      {super.key, required this.name,
      required this.address,
      required this.documentId,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(address),
        trailing: IconButton(
          icon: const Icon(Icons.delete,color: Colors.black,),
          onPressed: () {
            // Show a confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Delivery Address'),
                  content: const Text(
                      'Are you sure you want to delete this delivery address?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete the delivery address from Firestore based on documentId
                        await DeliveryAddress.deleteAddressFromFirestore(
                            documentId);

                        // Call the onDelete callback
                        onDelete(documentId);

                        // Optionally, you can display a SnackBar or perform other UI updates
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Delivery address deleted successfully!'),
                          ),
                        );

                        Navigator.pop(context); // Close the confirmation dialog
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  final String status;

  final VoidCallback onTap;

  const OrderCard({super.key,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          title: Text(orderNumber),
          subtitle: Text('Status: $status'),
          trailing: const Icon(Ionicons.information_circle_sharp,
          color: Colors.black,),
        ),
      ),
    );
  }
}


class PaymentMethodCard extends StatelessWidget {
  final String cardInfo;
  final String documentId; // Document ID from Firestore
  final Function(String) onDelete;

  const PaymentMethodCard({super.key,
    required this.cardInfo,
    required this.documentId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(cardInfo),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.black,),
          onPressed: () {
            // Show a confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Payment Method'),
                  content: const Text(
                      'Are you sure you want to delete this payment method?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete the payment method from Firestore based on documentId
                        await PaymentController.deletePaymentFromFirestore(
                            documentId);

                        // Optionally, you can display a SnackBar or perform other UI updates
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Payment method deleted successfully!'),
                          ),
                        );

                        onDelete(
                            documentId); // Notify the parent about the deletion
                        Navigator.pop(context); // Close the confirmation dialog
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
