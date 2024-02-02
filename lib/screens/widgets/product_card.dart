import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/product_screen.dart';
import 'package:flutter/foundation.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kcontentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductScreen(product: product),
            ),
          );
        },
        child: Stack(
          children: [
            if (product.images.isNotEmpty)
              _buildImageWidget(product.images[0])
            else
              const SizedBox.shrink(), // Placeholder for no image

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 150), // Ensure the text is below the image
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Rs./ ${product.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: kprimaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Icon(
                    Ionicons.heart_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {

      return Image.network(
        imageUrl,
        width: 112,
        height: 112,
        fit: BoxFit.cover,
      );
  }
}