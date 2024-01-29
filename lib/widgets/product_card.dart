import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/product_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    double width, height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Card(
        child: InkWell(
        onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProductScreen(product: product),
        ),
      );
    },
      child: Container(
        height: height * 0.3,
        width: width * 0.2 * 2 + 10,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 160,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(product.images.isNotEmpty
                          ? product.images[0]
                          : '',),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    "Rs. ${product.price}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xffad44f1)),
                  ),
                  Container(
                    child: Text(
                      product.title,
                      style: TextStyle(fontSize: 15),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
        )
    );
  }
}