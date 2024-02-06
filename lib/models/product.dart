import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:infantique/models/reviews.dart';
import 'package:infantique/models/userDetails.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double price;
  final String category;
  final double averageRating;
  int quantity;
  final String sellerId;

  final List<Review> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.price,
    required this.category,
    required this.quantity,
    required this.reviews,
    required this.sellerId,
    required this.averageRating

  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    data ??= {};

    List<String> imageUrls = List<String>.from(data['image'] ?? []);
    List<dynamic> reviewDataList = data['reviews'] ?? [];
    double averageRating = (data['averageRating'] ?? 0.0).toDouble();

    List<Review> productReviews = reviewDataList
        .map((reviewData) => Review.fromMap(reviewData))
        .toList();

    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      images: imageUrls,
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      reviews: productReviews,
      quantity: data['quantity'] ?? 0,
      sellerId: data['sellerId']?? '',
      averageRating: averageRating
    );
  }
}

class ProductService {
  final CollectionReference _productsCollection =
  FirebaseFirestore.instance.collection('products');
  FirebaseFirestore _firestore = FirebaseFirestore.instance;



  Future<List<Product>> getSearchedProducts({
    required String searchQuery,
  }) async {
    try {
      String lowerCaseQuery = searchQuery.toLowerCase();

      QuerySnapshot snapshot = await _productsCollection.get();

      List<Product> results = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) =>
      product.title.toLowerCase().contains(lowerCaseQuery) ||
          product.category.toLowerCase().contains(lowerCaseQuery))
          .toList();

      print('Products Fetched Successfully');
      return results;
    } catch (e) {
      print('Error fetching searched products: $e');
      return [];
    }
  }
  Future<List<Product>> getProductsForOrder(String orderId) async {
    try {
      CollectionReference itemsCollection = _firestore.collection('orders').doc(orderId).collection('items');
      QuerySnapshot itemsSnapshot = await itemsCollection.get();

      List<Product> products = [];

      for (QueryDocumentSnapshot itemDoc in itemsSnapshot.docs) {
        Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
        Product? productDetails = await getProductById(itemData['productId']);
        if (productDetails != null) {
          products.add(productDetails);
        }
      }

      return products;
    } catch (e) {
      print('Error fetching products for order: $e');
      throw Exception('Error fetching products for order. Please try again.');
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot<Object?> snapshot = await _productsCollection.doc(productId).get();
      if (snapshot.exists) {
        // If the document exists, convert it to a Product object
        return Product.fromFirestore(snapshot);
      } else {
        // If the document doesn't exist, return null or handle it as needed
        return null;
      }
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Error fetching product details. Please try again.');
    }
  }


  Future<List<Product>> getProducts({
    String? orderBy,
    bool descending = false,
    String? category,
  }) async {
    Query productsQuery = _productsCollection;

    // Apply sorting
    if (orderBy != null) {
      productsQuery = productsQuery.orderBy(orderBy, descending: descending);
    }

    // Apply filtering by category
    if (category != null) {
      productsQuery = productsQuery.where('category', isEqualTo: category);
    }

    QuerySnapshot snapshot = await productsQuery.get();

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
      List<Map<String, dynamic>> reviewDataList = product.reviews
          .map((review) => review.toMap())
          .toList();

      await _productsCollection.doc(product.id).update({
        'title': product.title,
        'description': product.description,
        'images': product.images,
        'price': product.price,
        'category': product.category,
        if (product.reviews.isNotEmpty) 'reviews': reviewDataList,
        // Add other fields as needed
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





  Future<String> fetchSellerName(String sellerId) async {
    try {
      // Replace this with your actual logic to fetch seller information from Firestore
      // Assuming you have a collection named 'sellers'
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (snapshot.exists) {
        return snapshot['name'].toString();
      } else {
        return 'Unknown Seller';
      }
    } catch (e) {
      print('Error fetching seller information: $e');
      throw e;
    }
  }

  Future<List<Review>> getProductReviews(String productId) async {
    try {
      // Assuming there is a separate collection for reviews named 'product_reviews'
      CollectionReference reviewsCollection = FirebaseFirestore.instance.collection('reviews');

      // Query reviews for the specific product ID
      QuerySnapshot reviewsSnapshot = await reviewsCollection.where('productId', isEqualTo: productId).get();

      // Extract reviews data
      List<Review> reviews = reviewsSnapshot.docs
          .map((reviewDoc) => Review.fromMap(reviewDoc.data() as Map<String, dynamic>))
          .toList();

      print('Fetched reviews: $reviews');
      return reviews;
    } catch (e) {
      print('Error fetching product reviews: $e');
      return [];
    }
  }


}
