import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MyOrder>> fetchOrders(String userId) async {
    try {
      // Reference to the "orders" collection
      CollectionReference ordersCollection = _firestore.collection('orders');

      // Fetch orders that match the provided userId
      QuerySnapshot ordersSnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      // Process the fetched orders
      List<MyOrder> orders = ordersSnapshot.docs.map((orderDoc) {
        Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
        return MyOrder.fromFirestore(orderDoc.id, orderData);
      }).toList();

      return orders;
    } catch (e) {
      // Handle the error as needed
      print('Error fetching orders: $e');
      throw Exception('Error fetching orders. Please try again.');
    }
  }
}

class MyOrder {
  final String orderId;
  final String status;
  final String orderNumber;
  // Add other order details as needed

  MyOrder(
      this.orderId,
      this.status,
      this.orderNumber
      );

  factory MyOrder.fromFirestore(String orderId, Map<String, dynamic> data) {
    return MyOrder(
      orderId,
      data['status'] ?? '',
      data['orderNumber'] ?? ''// replace with the actual field name in your Firestore document
      // Add other order details as needed
    );
  }
}
