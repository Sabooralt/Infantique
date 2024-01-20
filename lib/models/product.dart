import 'package:flutter/material.dart';

class Product {
  final String title;
  final String description;
  final String image;
  final double price;
  final List<Color> colors;
  final String category;
  final double rate;

  Product({
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.colors,
    required this.category,
    required this.rate,
  });
}

final List<Product> products = [
  Product(
    title: "Calming Baby Shampoo",
    description:
        "JOHNSON'S® Calming Shampoo gently cleanses to leave delicate skin and hair feeling healthy. It is enriched with NaturalCalm™ aromas, designed to help soothe and relax your baby before bedtime.",
    image: "assets/bath2.png",
    price: 120,
    colors: [
      Colors.deepPurple,
    ],
    category: "Baby Bath",
    rate: 4.8,
  ),
  Product(
    title: "Johnson's Baby Jelly",
    description:
        "JOHNSONâ€™S Baby Jelly Fragrance Free is specially formulated to protect newborn baby skin by creating a light protective barrier against wetness and preventing nappy rash. With clinically proven mildness, JOHNSONâ€™S Baby...",
    image: "assets/bath3.png",
    price: 120,
    colors: [
      Colors.lightBlue,
    ],
    category: "Baby Bath",
    rate: 4.8,
  ),
  Product(
    title: "Johnson's Baby Powder",
    description:
        "Johnson's Baby powder blossoms, delicate floral fragrance, clinically proven mild, keeps babies smelling fresh and fragrant longer. We love babies and we understand how important it is to keep baby’s skin fresh and comfortable.",
    image: "assets/bath4.png",
    price: 55,
    colors: [
      Colors.pinkAccent,
    ],
    category: "Baby Bath",
    rate: 4.8,
  ),
];
