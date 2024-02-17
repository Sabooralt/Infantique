import 'package:flutter/material.dart';
import 'package:infantique/models/cart_provider.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/cart_item.dart';
import 'package:provider/provider.dart';

class CartTile extends StatefulWidget {

  final CartItem item;
  final Function() onRemove;
  final Function() onAdd;
  final Function() onDelete;

  const CartTile({
    Key? key,
    required this.item,
    required this.onRemove,
    required this.onAdd,
    required this.onDelete
  }) : super(key: key);

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  late CartProvider cartProvider;
  @override
  void initState() {
    super.initState();
    cartProvider = Provider.of<CartProvider>(context, listen: false);// Fetch cart items
  }
  @override

  Widget build(BuildContext context){
        return  Consumer<CartProvider>(
          builder: (context, cartProvider, child) => Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      height: 85,
                      width: 85,
                      decoration: BoxDecoration(
                        color: kcontentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      // Display product image or placeholder
                      child: widget.item.product.images.isNotEmpty
                          ? Image.network(
                        widget.item.product.images[0],
                        fit: BoxFit.cover,
                      )
                          : const Placeholder(), // You can replace this with your placeholder widget
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.item.product.category,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Rs.${widget.item.product.price * widget.item.quantity}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: kcontentColor,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => widget.onRemove(),
                            iconSize: 18,
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.item.quantity.toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => widget.onAdd(),
                            iconSize: 18,
                            icon: const Icon(
                              Icons.add,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )  )
    ;
        }
}

