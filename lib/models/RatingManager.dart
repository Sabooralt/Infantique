import 'package:cloud_firestore/cloud_firestore.dart';

class RatingManager {
  static final RatingManager _instance = RatingManager._internal();

  factory RatingManager() {
    return _instance;
  }

  RatingManager._internal();

  double averageRating = 0.0;

  Future<double> getAverageRating(String productId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      if (snapshot.size == 0) {
        // No reviews found for the product
        print('600');
        return 600; // or return a default value
      }else{


      // Calculate the average rating
      double totalRating = snapshot.docs.fold(0.0, (sum, doc) => sum + ((doc['rating'] ?? 0) as num).toDouble());
      double averageRating = totalRating / snapshot.size;

      print('Average Rating: $averageRating');
      return averageRating;
      }

    } catch (e) {
      print('Error fetching average rating: $e');
      throw e;
    }
  }

  Future<int> getReviewsCount(String productId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .get();

      return snapshot.size;
    } catch (e) {
      print('Error fetching reviews count: $e');
      throw e;
    }
  }


}
