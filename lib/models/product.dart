import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;

    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
    );
  }
}

class ProductService {
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('products');

  Future<List<Product>> getProducts() async {
    QuerySnapshot snapshot = await _productsCollection.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  Future<void> addProduct(Product product) async {
    await _productsCollection.add({
      'title': product.title,
      'description': product.description,
      'image': product.image,
      'price': product.price,
      'category': product.category,
    });
  }

  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update({
      'title': product.title,
      'description': product.description,
      'image': product.image,
      'price': product.price,
      'category': product.category,
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }
}
