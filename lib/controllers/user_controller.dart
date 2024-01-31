import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';





class UserController {
  static User? user = FirebaseAuth.instance.currentUser;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> storeUserData(User user) async {
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    // Check if the user data already exists
    DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      // If the document doesn't exist, store the user data
      await usersCollection.doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        // Add other fields as needed
      });
    }

    // If the document exists, do nothing
  }

  Future<void> handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
      await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult =
        await _auth.signInWithCredential(credential);
        final User? user = authResult.user;

        // Save user data to Firestore and authentication table
        if (user != null) {
          await _saveUserDataToFirestore(user);
        }

        print('Google Sign-In success: ${user?.displayName}');
      }
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // Handle the error as needed
    }
  }
  Future<void> _saveUserDataToFirestore(User user) async {
    // Get a reference to the users collection in Firestore
    CollectionReference usersCollection =
    FirebaseFirestore.instance.collection('users');

    // Check if the user already exists in Firestore
    DocumentSnapshot userSnapshot =
    await usersCollection.doc(user.uid).get();

    if (!userSnapshot.exists) {
      // If the user doesn't exist, add them to Firestore
      await usersCollection.doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
      });
    } else {
      await usersCollection.doc(user.uid).update({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
      });
    }

    // Save user data to the authentication table
    await _auth.currentUser?.updateProfile(displayName: user.displayName,photoURL: user.photoURL);



    await _auth.currentUser?.reload();
  }

  static Future<bool> isUserSeller(String uid) async {
    DocumentSnapshot snapshot =
    await _firestore.collection('sellers').doc(uid).get();
    return snapshot.exists && snapshot.data() != null;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }
}