import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<Seller> getSellerInfo(String uid) async {
    try {
      DocumentSnapshot sellerSnapshot =
          await _firestore.collection('sellers').doc(uid).get();
      if (sellerSnapshot.exists) {
        // Create a Seller object using the data from Firestore
        return Seller(
          id: uid,
          name: sellerSnapshot['name'],
          // Add more fields as needed
        );
      } else {
        throw 'Seller not found';
      }
    } catch (e) {
      print('Error fetching seller information: $e');
      rethrow;
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
