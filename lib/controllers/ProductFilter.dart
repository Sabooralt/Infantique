import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infantique/models/product.dart';

class ProductFilter {
  ProductService productService = ProductService();

  Future<List<Product>> getProductsByCategory(String category) async {
    return await productService.getProducts(category: category);
  }

}