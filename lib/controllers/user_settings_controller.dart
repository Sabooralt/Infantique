import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class User_Settings_Controller {
  static Future<void> showAddAddressDialog(
      BuildContext context, Function(DeliveryAddress) onAddressAdded) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController addressController = TextEditingController();

    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String nameError = '';
    String addressError = '';

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Delivery Address'),
          content: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                Text(
                  nameError,
                  style: const TextStyle(color: Colors.red),
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an address';
                    }
                    return null;
                  },
                ),
                Text(
                  addressError,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  String name = nameController.text.trim();
                  String address = addressController.text.trim();
                  DeliveryAddress newAddress = DeliveryAddress(
                    name: name,
                    address: address,
                    documentId: '',
                  );

                  onAddressAdded(newAddress);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Delivery address added successfully!'),
                    ),
                  );

                  Navigator.pop(context);
                } else {

                  nameError = nameController.text.isEmpty
                      ? 'Please enter a name'
                      : '';
                  addressError = addressController.text.isEmpty
                      ? 'Please enter an address'
                      : '';
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }}


class DeliveryAddress {
  final String name;
  final String address;
  final String documentId;

  DeliveryAddress({required this.name, required this.address, required this.documentId});




  static Future<void> deleteAddressFromFirestore(String documentId) async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('delivery_addresses') // Update the collection name
          .doc(documentId)
          .delete();

      print('Delivery address deleted from Firestore!');
    } catch (e) {
      print('Error deleting delivery address from Firestore: $e');
    }
  }
}


class PaymentController {
  static Future<void> showAddPaymentMethodDialog(BuildContext context,
      Function(String) onPaymentMethodAdded) async {
    TextEditingController cardInfoController = TextEditingController();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String cardInfoError = '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment Method'),
          content: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: cardInfoController,
                  decoration: const InputDecoration(labelText: 'Card Info'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card information';
                    }
                    return null;
                  },
                ),
                Text(
                  cardInfoError,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  String newCardInfo = cardInfoController.text;
                  onPaymentMethodAdded(newCardInfo);
                  Navigator.pop(context);
                } else {
                  // Validate the form and update error messages

                  cardInfoError = cardInfoController.text.isEmpty
                      ? 'Please enter card information'
                      : '';
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> deletePaymentFromFirestore(String documentId) async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .collection('payment_methods')
          .doc(documentId)
          .delete();

      print('Payment method deleted from Firestore!');
    } catch (e) {
      print('Error deleting payment method from Firestore: $e');
    }
  }

}
