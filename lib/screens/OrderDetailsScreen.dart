import 'package:flutter/material.dart';
import 'package:infantique/models/orders_model.dart';
import 'package:infantique/models/product.dart';

class OrderDetailsScreen extends StatelessWidget {
  final String orderId;
  final String orderNumber;
  OrderDetailsScreen({
    required this.orderId,
    required this.orderNumber,
  });
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(orderNumber),
      ),
      body: FutureBuilder<List<MyOrder>>(
        future: _orderService.fetchOrderWithDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching orders: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders available.'));
          } else {
            // Access the order details from the first order in the list
            MyOrder firstOrder = snapshot.data!.first;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Number: ${firstOrder.orderNumber}'),
                    Text('Staus: ${firstOrder.status}'),
                    Text('Delivery Charges: ${firstOrder.orderDetails['deliveryCharges']}'),
                    Text('Sub Total: ${firstOrder.orderDetails['subtotal']}'),
                    Text(
                        'Total With Delivery: ${firstOrder.orderDetails['totalWithDelivery']}'),

                    const Divider(), // Add a divider between order details and product details
                    // Display details for each product in the order
                    for (MyOrder order in snapshot.data!) ...[
                      FutureBuilder<Product?>(
                        future: _productService.getProductById(order.productId),
                        builder: (context, productSnapshot) {
                          if (productSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (productSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error fetching product details: ${productSnapshot.error}'));
                          } else {
                            // Assuming you have a function to convert Product? to Product
                            Product product = productSnapshot.data!;
                            return OrderProductCard(
                              productId: order.productId,
                              quantity: order.quantity,
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class OrderProductCard extends StatelessWidget {
  final String productId;
  final int quantity;
  final ProductService _productService = ProductService();

  OrderProductCard({required this.productId, required this.quantity});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _productService.getProductById(productId),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (productSnapshot.hasError) {
          return Center(
              child: Text(
                  'Error fetching product details: ${productSnapshot.error}'));
        } else {
          // Assuming you have a function to convert Product? to Product
          Product product = productSnapshot.data!;

          // Use the product details in your card
          return Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(product.images[0]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs.${product.price.toString()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Qt.(${quantity.toString()})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
