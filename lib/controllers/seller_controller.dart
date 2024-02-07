import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SellerAuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getCurrentSellerId() async {
    try {
      // Check if there is a current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Access the user's UID (ID)
        String sellerId = user.uid;
        return sellerId;
      } else {
        // No authenticated user
        return null;
      }
    } catch (e) {
      print('Error getting current seller ID: $e');
      return null;
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return userCredential.user!;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSellers() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('sellers').get();
      return querySnapshot.docs
          .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      EasyLoading.showToast('Error fetching sellers: $e');
      return []; // Return an empty list if an error occurs
    }
  }

  Future<UserCredential> signUp(String email, String password,
      {required String name}) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Use the automatically generated UID from Firebase Authentication
      String uid = userCredential.user!.uid;

      await _firestore.collection('sellers').doc(uid).set({
        'name': name,
        'email': email,
        // Add any other fields you want to store
      });
      print(uid);
      return userCredential;
    } catch (e) {
      // Handle signup errors
      print('Error signing up: $e');
      rethrow; // Rethrow the error for the UI to handle
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}

class Seller {
  final String id;
  final String name;

  Seller({required this.id, required this.name});
}
