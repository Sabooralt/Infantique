import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAppUser {
  final String uid;
  final String displayName;
  final String email;

  MyAppUser({
    required this.uid,
    required this.displayName,
    required this.email,
  });
}

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  _UsersContentState createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Future<List<MyAppUser>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();
  }
  Future<void> _disableUser(String uid) async {
    try {
      // Update the user status in Firestore
      await _firestore.collection('users').doc(uid).update({
        'disabled': true,
      });
      _showSnackbar('User disabled successfully!', true);
    } catch (error) {
      _showSnackbar('Error disabling user: $error', true);

    }
    setState(() {});
  }

  Future<void> _deleteUser(String uid) async {
    try {
      // Delete the user from Firebase Authentication
      await _auth.currentUser!.delete();

      // Remove the user's document from Firestore
      await _firestore.collection('users').doc(uid).delete();

      _showSnackbar('User deleted successfully!', true);
    } catch (error) {
      _showSnackbar('Error deleting users: $error', true);
    }
  }
  Future<List<MyAppUser>> _fetchUsers() async {
    List<MyAppUser> users = [];

    try {
      // Query all user documents from Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('users').get();

      users = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return MyAppUser(
          uid: doc.id,
          displayName: data['name'] ?? '',
          email: data['email'] ?? '',
        );
      }).toList();

    } catch (error) {
      _showSnackbar('Error fetching users: $error', true);
    }
    setState(() {});

    return users;
  }
  void _showSnackbar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Users',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MyAppUser>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<MyAppUser> users = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    MyAppUser user = users[index];

                    return Card(
                      child: ListTile(
                        title: Text(user.displayName),
                        subtitle: Text(user.email),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _disableUser(user.uid);
                                _showSnackbar('User disabled successfully', true);
                              },
                              child: const Text('Disable'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                _deleteUser(user.uid);
                                _showSnackbar('User deleted successfully', true);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

}
