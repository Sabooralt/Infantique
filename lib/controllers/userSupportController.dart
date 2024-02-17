import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class UserSupportController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  CollectionReference issuesCollection = FirebaseFirestore.instance.collection('issues');
  CollectionReference contactCollection = FirebaseFirestore.instance.collection('contact');

  Future<void> submitFeedback(String subject, String description) async {
    User? user = _auth.currentUser;
    EasyLoading.show();
    if (user != null) {

      await feedbackCollection.add({
        'userId': user.uid,
        'subject': subject,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });
      EasyLoading.dismiss();
      EasyLoading.showToast('Feedback Submitted Successfully!');
    }else{
      EasyLoading.dismiss();
      EasyLoading.showToast('Oops! Something went wrong. Please try again later.');
    }

  }

  Future<void> reportIssue(String issue) async {
    User? user = _auth.currentUser;
    EasyLoading.show();
    try {
      if (user != null) {
        await issuesCollection.add({
          'userId': user.uid,
          'issue': issue,
          'timestamp': FieldValue.serverTimestamp(),
        });
        EasyLoading.dismiss();
        EasyLoading.showToast(
            'Issues reported successfully! Thank you for your feedback.');
      }
    }catch(e){
      EasyLoading.dismiss();
      EasyLoading.showToast(
          'Oops! Something went wrong. Please try again later.');
    }
  }
  Future<void> SubmitContactUs(String subject, String description, String email , String? phone) async {
    User? user = _auth.currentUser;
    EasyLoading.show();
    try {
      if (user != null) {
        await contactCollection.add({
          'userId': user.uid,
          'subject': subject,
          'description': description,
          'email': email,
          'phone': phone ?? 'No Phone Number.',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      EasyLoading.dismiss();
      EasyLoading.showToast('Thank you for contacting us. We\'ll get back to you soon.');
    }catch(e){
EasyLoading.dismiss();
EasyLoading.showToast('Oops! Something went wrong. Please try again later.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFeedbacks() async {
    try {
      // Replace 'feedbacks' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('feedback').get();

      List<Map<String, dynamic>> feedbacks = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      doc.data() as Map<String, dynamic>)
          .toList();

      return feedbacks;
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchIssues() async {
    try {
      // Replace 'feedbacks' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('issues').get();

      List<Map<String, dynamic>> issues = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      doc.data() as Map<String, dynamic>)
          .toList();

      return issues;
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchContact() async {
    try {
      // Replace 'feedbacks' with your actual collection name
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('contact').get();

      List<Map<String, dynamic>> contact = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      doc.data() as Map<String, dynamic>)
          .toList();

      return contact;
    } catch (e) {
      print('Error fetching feedbacks: $e');
      return [];
    }
  }


  Future<List<Map<String, dynamic>>> getIssues() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await issuesCollection.where('userId', isEqualTo: user.uid).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getContactRequests() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot snapshot = await contactCollection.where('userId', isEqualTo: user.uid).get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }
}
