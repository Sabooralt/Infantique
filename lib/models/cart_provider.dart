import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String userId = '';

  late List<CartItem> cartItems; // Use late for late initialization

  CartProvider() {
    cartItems = []; // Initialize the list in the constructor
  }

  void clearCart() {
    cartItems.clear();
    notifyListeners();
  }
  DateTime currentDateTime = DateTime.now();



  Future<void> placeOrder(String deliveryAddress, Map<String, dynamic> orderDetails) async {
    try {
      // Get the current user's ID from Firebase Authentication
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the "orders" collection
      CollectionReference ordersCollection = firestore.collection('orders');

      // Create a new order document
      DocumentReference orderDocument = await ordersCollection.add({
        'userId': userId,
        'deliveryAddress': deliveryAddress,
        'orderNumber': generateOrderNumber(),
        'status': 'Processing',
        'orderDetails': orderDetails,
        'timestamp': currentDateTime,

      });


      CollectionReference itemsCollection = orderDocument.collection('items');

      // Save each item in the order
      for (CartItem item in cartItems) {
        await itemsCollection.add({
          'productId': item.product.id,
          'quantity': item.quantity,


        });
      }


      this.clearCart();
      notifyListeners();

      print('Order placed successfully!');
    } catch (e) {
      print('Error placing order: $e');
      // Handle the error as needed
    }
  }

  String generateOrderNumber() {
    // Generate a random 6-digit order number
    int orderNumber = Random().nextInt(900000) + 100000;
    return 'ORD$orderNumber';
  }
  void setUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Check if there is a currently signed-in user
    if (auth.currentUser != null) {
      userId = auth.currentUser!.uid;
    }
  }

  Future<void> addToCart(Product product, int quantity) async {
    if (auth.currentUser != null) {
      userId = auth.currentUser!.uid;
    }
    // Check if the product is already in the cart
    bool productExists = cartItems.any((item) => item.product == product);

    if (productExists) {
      // Update quantity if the product is already in the cart
      cartItems.firstWhere((item) => item.product == product).quantity += quantity;
    } else {
      // Add a new item to the cart
      cartItems.add(CartItem(quantity: quantity, product: product));
    }

    // Save cart data to Firebase Firestore
    await saveCartToFirestore();

    notifyListeners();
  }

  Future<void> saveCartToFirestore() async {
    if (auth.currentUser != null) {
      userId = auth.currentUser!.uid;
    }
    try {
      // Save cartItems to Firestore
      final CollectionReference cartCollection = firestore.collection('carts').doc(userId).collection('items');

      // Clear existing items and add updated items
      await cartCollection.get().then((snapshot) {
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      for (CartItem item in cartItems) {
        await cartCollection.add({
          'productId': item.product.id,
          'quantity': item.quantity,
        });
      }
      print('Items Added To Cart Successfully! $userId');
    } catch (e) {
      print('Error saving cart to Firestore: $e');
    }
  }

  Future<void> fetchCartItems() async {
    try {
      // Check if userId is set
      if (userId.isEmpty) {
        throw Exception('User ID is not set.');
      }

      // Retrieve cart items from Firestore
      QuerySnapshot snapshot = await firestore.collection('carts').doc(userId).collection('items').get();

      // Convert documents to CartItem objects
      cartItems = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        String productId = doc['productId'];

        // Fetch product details based on productId
        DocumentSnapshot productDoc = await firestore.collection('products').doc(productId).get();

        if (productDoc.exists) {
          Product product = Product.fromFirestore(productDoc);
          int quantity = doc['quantity'] ?? 0;

          cartItems.add(CartItem(
            quantity: quantity,
            product: product,
          ));
        }
      }
print('items fetched');
      notifyListeners();
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  Future<void> deleteCartItem(CartItem cartItem) async {
    try {
      // Check if userId is set
      if (userId.isEmpty) {
        throw Exception('User ID is not set.');
      }

      // Reference to the 'items' collection
      CollectionReference itemsCollection =
      firestore.collection('carts').doc(userId).collection('items');

      // Find the document reference for the given cart item
      QuerySnapshot snapshot = await itemsCollection
          .where('productId', isEqualTo: cartItem.product.id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Delete the document
        await itemsCollection.doc(snapshot.docs.first.id).delete();
        // Remove the cart item from the local list
        cartItems.remove(cartItem);
        // Notify listeners about the change
        notifyListeners();
      } else {
        print('Document not found for productId: ${cartItem.product.id}');
      }
    } catch (e) {
      print('Error deleting cart item: $e');
    }
  }

  // Function to change the quantity of a cart item
  Future<void> changeQuantity(CartItem cartItem, int newQuantity) async {
    try {
      // Check if userId is set
      if (userId.isEmpty) {
        throw Exception('User ID is not set.');
      }

      // Reference to the 'items' collection
      CollectionReference itemsCollection =
      firestore.collection('carts').doc(userId).collection('items');

      // Find the document reference for the given cart item
      QuerySnapshot snapshot = await itemsCollection
          .where('productId', isEqualTo: cartItem.product.id)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update the quantity in the document
        await itemsCollection.doc(snapshot.docs.first.id).update({
          'quantity': newQuantity,
        });

        // Update the quantity in the local cartItems list
        cartItem.quantity = newQuantity;

        // Notify listeners about the change
        notifyListeners();
      } else {
        print('Document not found for productId: ${cartItem.product.id}');
      }
    } catch (e) {
      print('Error changing quantity: $e');
    }
  }

  // Function to update the cart in Firestore


// Add more methods for loading cart data, clearing the cart, etc.
}