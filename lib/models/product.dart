import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String category;
  final List<String> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.category,
    required this.reviews,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    data ??= {};

    List<String> imageUrls = List<String>.from(data['image'] ?? []);
    List<String> productReviews = List<String>.from(data['reviews'] ?? []);

    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: imageUrls,
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      reviews: productReviews,
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

  Future<List<Product>> getProductsForSeller(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _productsCollection
          .where('sellerId', isEqualTo: sellerId)
          .get();
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
  Future<void> addProduct(Product product, String sellerId) async {
    if (_isValidCategory(product.category)) {
      await _productsCollection.add({
        'title': product.title,
        'description': product.description,
        'image': product.images,
        'price': product.price,
        'category': product.category,
        'sellerId': sellerId, // Include the seller ID

      });
    } else {
      throw Exception('Invalid category selected');
    }
  }

  Future<void> updateProduct(Product product) async {
    if (_isValidCategory(product.category)) {
      await _productsCollection.doc(product.id).update({
        'title': product.title,
        'description': product.description,
        'images': product.images,
        'price': product.price,
        'category': product.category,
        'reviews': product.reviews,
      });
    } else {
      throw Exception('Invalid category selected');
    }
  }
  Future<void> deleteImagesFromStorage(List<String> imageUrls) async {
    try {
      for (String imageUrl in imageUrls) {
        firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl);
        await storageReference.delete();
      }
    } catch (error) {
      print("Error deleting images from storage: $error");
      throw error; // You might want to handle or log the error accordingly
    }
  }


  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  bool _isValidCategory(String category) {
    List<String> allowedCategories = ['feeding', 'bath', 'safety', 'diapers', 'toys'];
    return allowedCategories.contains(category);
  }
}
