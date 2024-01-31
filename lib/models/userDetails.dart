import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String userId;
  final String username;
  final String userPicUrl;

  UserDetails({
    this.userId = '',
    this.username = '',
    this.userPicUrl = '',
  });


}
Future<UserDetails> fetchUserDetails(String userId) async {
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  DocumentSnapshot userSnapshot = await usersCollection.doc(userId).get();

  if (userSnapshot.exists) {
    return UserDetails(
      userId: userId,
      username: userSnapshot['displayName'],
      userPicUrl: userSnapshot['photoURL'],
    );
  } else {
    // Handle the case where user details are not found
    return UserDetails(
      userId: userId,
      username: 'Unknown User',
      userPicUrl: 'default_userpic_url',
    );
  }
}

