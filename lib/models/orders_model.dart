import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infantique/models/product.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();

  Future<List<MyOrder>> fetchAllOrdersWithDetails() async {
    try {
      CollectionReference ordersCollection = _firestore.collection('orders');

      // Fetch all orders from the main orders collection
      QuerySnapshot ordersSnapshot = await ordersCollection.get();

      List<MyOrder> orders = [];

      // Process each order from the main collection
      for (QueryDocumentSnapshot orderDoc in ordersSnapshot.docs) {
        // Get data from the order document
        Map<String, dynamic>? orderData = orderDoc.data() as Map<String, dynamic>?;

        if (orderData == null) {
          // Handle the case where order data is null
          print('Order data is null for order ${orderDoc.id}');
          continue;
        }

        print('Order Data: $orderData');

        // Fetch order details using the orderDetails field
        Map<String, dynamic>? orderDetails = orderData['orderDetails'] as Map<String, dynamic>?;

        if (orderDetails == null) {
          // Handle the case where order details are null
          print('Order details are null for order ${orderDoc.id}');
          continue;
        }

        print('Order Details: $orderDetails');

        // Fetch items from the "items" subcollection for each order
        CollectionReference itemsCollection = orderDoc.reference.collection('items');
        QuerySnapshot itemsSnapshot = await itemsCollection.get();

        print('Items Data for order ${orderDoc.id}: ${itemsSnapshot.docs.map((doc) => doc.data())}');

        // Process each item from the subcollection
        for (QueryDocumentSnapshot itemDoc in itemsSnapshot.docs) {
          // Get data from the item document
          Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;

          // Fetch product details using the product ID from the item document


          // Create a MyOrder instance with both order and product details
          MyOrder order = MyOrder.fromFirestore(orderDoc.id, orderData, orderDetails, itemData);
          orders.add(order);
        }
      }

      print('Success fetching all orders: $orders');
      return orders;
    } catch (e) {
      print('Error fetching all orders: $e');
      throw Exception('Error fetching orders. Please try again.');
    }
  }









  Future<List<MyOrder>> fetchOrderWithDetails(String orderId) async {
    try {
      CollectionReference ordersCollection = _firestore.collection('orders');
      CollectionReference itemsCollection = ordersCollection.doc(orderId).collection('items');

      // Fetch items from the "items" subcollection
      QuerySnapshot itemsSnapshot = await itemsCollection.get();

      // Fetch the order details from the main orders collection
      DocumentSnapshot orderSnapshot = await ordersCollection.doc(orderId).get();
      Map<String, dynamic> orderData = orderSnapshot.data() as Map<String, dynamic>;

      // Fetch order details using the orderDetails field
      Map<String, dynamic> orderDetails = orderData['orderDetails'] as Map<String, dynamic>;

      List<MyOrder> orders = [];

      // Process each item from the subcollection
      for (QueryDocumentSnapshot itemDoc in itemsSnapshot.docs) {
        // Get data from the item document
        Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;

        // Fetch product details using the product ID from the item document
        Product? productDetails = await _productService.getProductById(itemData['productId']);

        // Create a MyOrder instance with both order and product details
        MyOrder order = MyOrder.fromFirestore(orderId, orderData, orderDetails, itemData);
        orders.add(order);
      }

      print('Success orders $orders');
      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Error fetching orders. Please try again.');
    }
  }





  Future<List<MyOrder>> fetchOrders(String userId) async {
    try {
      // Reference to the "orders" collection
      CollectionReference ordersCollection = _firestore.collection('orders');

      // Fetch orders that match the provided userId
      QuerySnapshot ordersSnapshot = await ordersCollection
          .where('userId', isEqualTo: userId)
          .get();

      // Process the fetched orders
      List<MyOrder> orders = [];

      // Process each order document
      for (QueryDocumentSnapshot orderDoc in ordersSnapshot.docs) {
        // Get data from the order document
        Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;

        // Fetch order details using the orderDetails field
        Map<String, dynamic>? orderDetails = orderData['orderDetails'] as Map<String, dynamic>?;

        // Check if orderDetails is not null and of the expected type
        if (orderDetails != null && orderDetails is Map<String, dynamic>) {
          // Create a MyOrder instance with order details
          MyOrder order = MyOrder.fromFirestore(orderDoc.id, orderData, orderDetails, {});
          orders.add(order);
        } else {
          print('Error: orderDetails is null or not of type Map<String, dynamic>');
        }
      }

      return orders;
    } catch (e) {
      // Handle the error as needed
      print('Error fetching orders: $e');
      throw Exception('Error fetching orders. Please try again.');
    }
  }



  Future<DocumentSnapshot> fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await _firestore.collection('products').doc(productId).get();
      return productSnapshot;
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Error fetching product details. Please try again.');
    }
  }
}


class MyOrder {
  final String orderId;
  final String status;
  final String orderNumber;
  final int quantity;
  final String productId;
  final String userId;
  final Map<String, dynamic> orderDetails;

  MyOrder({
    required this.orderId,
    required this.status,
    required this.quantity,
    required this.orderNumber,
    required this.productId,
    required this.orderDetails,
    required this.userId
  });

  factory MyOrder.fromFirestore(String orderId, Map<String, dynamic> orderData, Map<String, dynamic> orderDetails, Map<String, dynamic> itemData) {
    return MyOrder(
      orderId: orderId,
      status: orderData['status'] ?? '',
      orderNumber: orderData['orderNumber'] ?? '',
      productId: itemData['productId'] ?? '',
      quantity: itemData['quantity'] ?? 0,
      orderDetails: orderDetails ?? {},
      userId:  orderData['userId'],
    );
  }
}

