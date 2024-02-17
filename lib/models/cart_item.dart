import 'package:infantique/models/product.dart';

class CartItem {
  int quantity;
  Product product;
  double getTotalPrice() {
    return quantity * product.price;
  }
  CartItem({
    required this.quantity,
    required this.product,
  });
}

List<CartItem> cartItems = [

];
