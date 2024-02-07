import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/RatingManager.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/product_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalReviews();
  }

  Future<void> _loadTotalReviews() async {
    try {
      RatingManager ratingManager = RatingManager();
      int reviewsCount = await ratingManager.getReviewsCount(widget.product.id);

      ProductService productService = ProductService();
      String sellerName =
          await productService.fetchSellerName(widget.product.sellerId);

      setState(() {
        totalReviews = reviewsCount;
      });

      print('$totalReviews, $sellerName');
    } catch (e) {
      print('Error loading average rating and seller name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: double.infinity,
        child: Card(
            child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductScreen(product: widget.product),
                    ),
                  );
                },
                child: Container(
                  child: Container(
                    height: 290,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                widget.product.images.isNotEmpty
                                    ? widget.product.images[0]
                                    : '',
                              ),
                            ),
const SizedBox(height: 7,),
                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    widget.product.title,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Row(
                              children: [

                                Icon(Ionicons.star, color: Colors.amberAccent, size: 15,),
                                const SizedBox(width: 3),
                                Text(
                                  '${widget.product.averageRating}/5($totalReviews)',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.7)),
                                )
                              ],
                            ),
                            const SizedBox(height: 7,),
                            Row(
                              children: [
                                Text(
                                  'Rs. ${widget.product.price}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kprimaryColor),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
