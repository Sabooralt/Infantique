import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/cart_provider.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/widgets/custom_app_bar.dart';
import 'package:infantique/widgets/cart_tile.dart';
import 'package:infantique/widgets/check_out_box.dart';
import 'package:ionicons/ionicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:infantique/models/cart_item.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartProvider cartProvider;

  @override
  void initState() {
    super.initState();
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.setUserId(); // Set the userId
    cartProvider.fetchCartItems(); // Fetch cart items
  }

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
        backgroundColor: kcontentColor,
       appBar: Custom_Appbar( title: Text('My Cart'),),
        bottomSheet: Visibility(
          visible: cartProvider.cartItems.isNotEmpty,
          child: CheckOutBox(
            items: cartProvider.cartItems,
          ),
        ),
        body: cartProvider.cartItems.isEmpty
            ? const Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : Consumer<CartProvider>(
                builder: (context, cartProvider, child) => ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemBuilder: (context, index) => CartTile(
                        item: cartProvider.cartItems[index],
                        onRemove: () {
                          onRemoveCartItem(index);
                        },
                        onAdd: () {
                          onAddCartItem(index);
                        },
                        onDelete: () {
                          onDeleteCartItem(index);
                        },
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 20),
                      itemCount: cartProvider.cartItems.length,
                    )));
  }

  void onDeleteCartItem(int index) {
    // Check if the index is within the valid range
    if (index >= 0 && index < cartProvider.cartItems.length) {
      // Call the deleteCartItem function from CartProvider
      cartProvider.deleteCartItem(cartProvider.cartItems[index]);
      Future.delayed(Duration(milliseconds: 300), () {
        EasyLoading.showToast(duration: Duration(milliseconds: 1200),'Item deleted successfully!', dismissOnTap: true, );
      });

    }
  }

  // Function to remove a cart item by index
  void onRemoveCartItem(int index) {
    // Check if the index is within the valid range
    if (index >= 0 && index < cartProvider.cartItems.length) {
      // Decrease the quantity by 1 using changeQuantity function
      cartProvider.changeQuantity(cartProvider.cartItems[index],
          cartProvider.cartItems[index].quantity - 1);
      print('$index bsadhlkad');
    } else {
      print('$index nope');
    }
  }

  // Function to add a cart item by index
  void onAddCartItem(int index) {
    // Check if the index is within the valid range
    if (index >= 0 && index < cartProvider.cartItems.length) {
      // Increase the quantity by 1 using changeQuantity function
      cartProvider.changeQuantity(cartProvider.cartItems[index],
          cartProvider.cartItems[index].quantity + 1);
      print('$index bsadhlkad');
    } else {
      print('$index nope');
    }
  }
}
