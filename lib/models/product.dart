import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.category,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    // Ensure data is not null
    data ??= {};

    List<String> imageUrls = List<String>.from(data['images'] ?? []);
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: imageUrls,
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
      'image': product.images,
      'price': product.price,
      'category': product.category,
    });
  }

  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update({
      'title': product.title,
      'description': product.description,
      'image': product.images,
      'price': product.price,
      'category': product.category,
    });
  }

  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }
}
