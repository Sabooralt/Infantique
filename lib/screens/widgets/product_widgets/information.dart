import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:infantique/models/RatingManager.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/product.dart';

class ProductInfo extends StatefulWidget {
  final Product product;

  const ProductInfo({Key? key, required this.product}) : super(key: key);

  @override
  _ProductInfoState createState() => _ProductInfoState();

  Future<String> fetchSellerName(String sellerId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> sellerSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (sellerSnapshot.exists) {
        return sellerSnapshot['name'] ?? 'Unknown Seller';
      } else {
        return 'Unknown Seller';
      }
    } catch (e) {
      print('Error fetching seller name: $e');
      throw e;
    }
  }
}

class _ProductInfoState extends State<ProductInfo> {
  double averageRating = 0.0;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadAverageRating();
  }

  Future<void> _loadAverageRating() async {
    RatingManager ratingManager = RatingManager();
    double rating = await ratingManager.getAverageRating(widget.product.id);
    int reviewsCount = await ratingManager.getReviewsCount(widget.product.id);

    setState(() {
      averageRating = rating;
      totalReviews = reviewsCount;
    });
    print('$averageRating , $totalReviews');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rs. ${widget.product.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: kprimaryColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Ionicons.star,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$averageRating / 5', // Display average rating
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 10),
                  Text('Total Reviews: $totalReviews', style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: "Seller: "),
                  TextSpan(
                    text: 'Loading',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ],
    );
  }
}
