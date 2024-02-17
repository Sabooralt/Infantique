import 'package:flutter/material.dart';
import 'package:infantique/models/cart_item.dart';

class CheckOutBox extends StatelessWidget {
  final List<CartItem> items;
  double totalAmount = 0;
  int deliveryCharges = 0;
  double totalWithDelivery = 0;

  CheckOutBox({
    Key? key,
    required this.items,
  }) : super(key: key) {
    // Calculate totals when the CheckOutBox is created
    totalAmount = items.fold(
      0,
          (previousValue, item) =>
      previousValue + (item.product.price * item.quantity),
    );

    deliveryCharges = items.length <= 1 ? 120 : 200;
    totalWithDelivery = totalAmount + deliveryCharges.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Subtotal",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Rs.${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Delivery Charges",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                "Rs.${deliveryCharges.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Rs.${totalWithDelivery.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> getOrderDetails() {
    return {
      'subtotal': totalAmount,
      'deliveryCharges': deliveryCharges,
      'totalWithDelivery': totalWithDelivery.toStringAsFixed(2),
      // ... other order details ...
    };
  }
}
