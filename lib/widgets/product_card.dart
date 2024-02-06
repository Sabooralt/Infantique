import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infantique/constants.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/product_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: double.infinity,
        child: Card(
            child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(product: product),
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
                                product.images.isNotEmpty
                                    ? product.images[0]
                                    : '',
                              ),
                            ),
const SizedBox(height: 7,),
                            Row(
                              children: [

                                Expanded(
                                  child: Text(
                                    product.title,
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
                                Text('${product.averageRating}/5(10)',style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black.withOpacity(0.7)
                                ),)
                              ],
                            ),
                            const SizedBox(height: 7,),
                            Row(
                              children: [
                                Text(
                                  'Rs. ${product.price}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kprimaryColor
                                  ),
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
