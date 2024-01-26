import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';





class UserController {
  static User? user = FirebaseAuth.instance.currentUser;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  static Future<User?> loginWithGoogle() async {
    final googleAccount = await GoogleSignIn().signIn();

    final googleAuth = await googleAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    // Check if the signed-in user is a seller
    bool isSeller = await isUserSeller(userCredential.user!.uid);

    print('UID: ${userCredential.user!.uid}, Is Seller: $isSeller');

    // If the user is a seller, show an error message and return null
    if (isSeller) {
      print('Error: Seller accounts are not allowed in the user section.');
      return null;
    }

    return userCredential.user;
  }

  static Future<bool> isUserSeller(String uid) async {
    DocumentSnapshot snapshot = await _firestore.collection('sellers').doc(uid).get();
    return snapshot.exists && snapshot.data() != null;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}
