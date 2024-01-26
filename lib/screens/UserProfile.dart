import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/EditUserProfile.dart';
import 'package:infantique/controllers/user_controller.dart';
import 'package:infantique/controllers/user_settings_controller.dart';
import 'package:infantique/screens/login_screen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/screens/user/change_password.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<DeliveryAddress> deliveryAddresses = [];
  List<Map<String, dynamic>> paymentMethods = [];
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
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Addresses Section
            SectionTitle('Delivery Addresses'),


            ListTile(
              title: Text('Add Delivery Address'),
              leading: Icon(Icons.add),
              onTap: () {
                User_Settings_Controller.showAddAddressDialog(context, (newAddress) async {
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
                        paymentMethods.removeWhere((method) => method['documentId'] == deletedId);
                      });
                    },
                  ),
              ],
            ),




            /* for (DeliveryAddress address in deliveryAddresses)
              DeliveryAddressCard(
                address.name,
                address.address,
              ),*/





            // Orders Section
            SectionTitle('Orders'),
            OrderCard('Order #1', 'Delivered'),
            OrderCard('Order #2', 'In Progress'),

            // Profile Settings Section
            SectionTitle('Profile Settings'),
            ListTile(
              title: Text('Edit Profile'),
              leading: Icon(Icons.person),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => EditProfileScreen(),
                )
                );
              },
            ),
            ListTile(
              title: Text('Change Password'),
              leading: Icon(Icons.lock),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    )
                );
              },
            ),

            // Payment Methods Section
            SectionTitle('Payment Methods'),
            ListTile(
              title: Text('Add Payment Method'),
              leading: Icon(Icons.add),
              onTap: () {
                PaymentController.showAddPaymentMethodDialog(context, (newPaymentMethod) async {
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
                    SnackBar(
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
                        paymentMethods.removeWhere((method) => method['documentId'] == deletedId);
                      });
                    },
                  ),
              ],
            ),


            // Logout Section
            SectionTitle('Logout'),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.exit_to_app),
              onTap: () async {
                // Show loading indicator with "Logging Out..." text
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
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
                  await Future.delayed(Duration(seconds: 2));

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
                  Navigator.pop(context);  // Close the loading indicator
                }
              },

            ),
          ],
        ),
      ),
    );

  }
//Retrieve Delivery address from firebase

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

  SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class DeliveryAddressCard extends StatelessWidget {
  final String name;
  final String address;
  final String documentId;
  final Function(String) onDelete;

  DeliveryAddressCard({required this.name, required this.address, required this.documentId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(address),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // Show a confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Delivery Address'),
                  content: Text('Are you sure you want to delete this delivery address?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete the delivery address from Firestore based on documentId
                        await DeliveryAddress.deleteAddressFromFirestore(documentId);

                        // Call the onDelete callback
                        onDelete(documentId);

                        // Optionally, you can display a SnackBar or perform other UI updates
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Delivery address deleted successfully!'),
                          ),
                        );

                        Navigator.pop(context); // Close the confirmation dialog
                      },
                      child: Text('Delete'),
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
  final String orderNumber;
  final String status;

  OrderCard(this.orderNumber, this.status);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(orderNumber),
        subtitle: Text('Status: $status'),
        trailing: IconButton(
          icon: Icon(Icons.info),
          onPressed: () {
            // Implement order details screen
          },
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  final String cardInfo;
  final String documentId; // Document ID from Firestore
  final Function(String) onDelete;

  PaymentMethodCard({
    required this.cardInfo,
    required this.documentId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(cardInfo),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // Show a confirmation dialog before deleting
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Delete Payment Method'),
                  content: Text('Are you sure you want to delete this payment method?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Delete the payment method from Firestore based on documentId
                        await PaymentController.deletePaymentFromFirestore(documentId);

                        // Optionally, you can display a SnackBar or perform other UI updates
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Payment method deleted successfully!'),
                          ),
                        );

                        onDelete(documentId); // Notify the parent about the deletion
                        Navigator.pop(context); // Close the confirmation dialog
                      },
                      child: Text('Delete'),
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
