import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infantique/models/reviews.dart';

class ReviewForm extends StatefulWidget {
  final Function(Review) onSubmit;
  final String productId; // Add a field to store the productId

  ReviewForm({
    required this.onSubmit,
    required this.productId, // Include the productId in the constructor
  });

  @override
  _ReviewFormState createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 0.0;
  String? loggedInUserId;
  String errorMessage = '';


  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      loggedInUserId = user.uid;
      print('Current User ID: $loggedInUserId');
    } else {
      print('No user is currently logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Write a Review'),
      content: Column(
        children: [
          TextField(
            controller: _commentController,
            decoration: InputDecoration(labelText: 'Your Comment'),
          ),
          SizedBox(height: 20,),
          Text('Rate Product:'),
          SizedBox(height: 10,),
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 20,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              _selectedRating = rating;
            },
          )

        ],

      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the review form dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _initializeCurrentUser(); // Ensure that the user ID is fetched

            final comment = _commentController.text;

            // Check if the comment is not empty
            if (comment.isNotEmpty && loggedInUserId != null) {
              final review = Review(
                userId: loggedInUserId!,
                comment: comment,
                productId: widget.productId,
                rating: _selectedRating, // Rating can be 0
              );

              widget.onSubmit(review); // Submit the review

              // Save the review to Firestore
              await saveReviewToFirestore(review);
            } else {
              // Update the error message
              errorMessage = 'Please fill in the comment.';
              print(errorMessage);
            }

            Navigator.pop(context); // Close the review form dialog
          },
          child: Text('Submit'),
        ),

        // Display the error message on the UI
        SizedBox(height: 10), // Adjust the height as needed
        if (errorMessage.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.red, // You can customize the color
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white), // You can customize the style
            ),
          ),
      ],
    );
  }

  Future<double> _calculateAverageRating(String productId) async {
    // Fetch the reviews for the specific product
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.size == 0) {
      // No reviews found for the product
      return 0; // or return a default value
    }

    // Calculate the average rating
    double totalRating = snapshot.docs.fold(0.0, (sum, doc) => sum + ((doc['rating'] ?? 0) as num).toDouble());
    double averageRating = totalRating / snapshot.size;

    // Format the result to 2 decimal places
    return double.parse(averageRating.toStringAsFixed(2));
  }

  Future<void> _updateProductAverageRating(String productId, double averageRating) async {
    // Update the product document with the new average rating
    await FirebaseFirestore.instance.collection('products').doc(productId).update({
      'averageRating': averageRating,
    });

    print('Product average rating updated successfully');
  }


  Future<void> saveReviewToFirestore(Review review) async {
    try {
      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toMap());
      double averageRating = await _calculateAverageRating(review.productId);
      await _updateProductAverageRating(review.productId, averageRating);// Convert the review object to a map
    } catch (e) {
      print('Error saving review to Firestore: $e');
      // Rethrow the exception to handle it in the calling method
      throw e;
    }
  }
}
