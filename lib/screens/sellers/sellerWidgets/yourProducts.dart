import 'package:flutter/material.dart';
import 'package:infantique/admin_panel/UpdateProductScreen.dart';
import 'package:infantique/controllers/seller_controller.dart';
import 'package:infantique/models/product.dart';

class YourProductsWidget extends StatefulWidget {
  @override
  State<YourProductsWidget> createState() => _YourProductsWidgetState();
}

class _YourProductsWidgetState extends State<YourProductsWidget> {
  SellerAuthController _sellerAuthController = SellerAuthController();
  ProductService _productService = ProductService();


  List<Product> products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
  }
  Future<void> refreshProducts() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSellerProducts();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSellerProducts() async {
    try {
      // Get the current seller's ID
      String? currentSellerId = await _sellerAuthController.getCurrentSellerId();

      if (currentSellerId != null) {
        // Fetch products for the current seller using ProductService
        List<Product> sellerProducts = await _productService.getProductsForSeller(currentSellerId);

        setState(() {
          // Update the state with the fetched products
          products = sellerProducts;
        });
      } else {
        // No authenticated seller, handle accordingly
        print('No authenticated seller');
      }
    } catch (e) {
      print('Error loading seller products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const Center(
          child: Text(
            'Your Products',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Your Products',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async{
                 await refreshProducts(); // Manually trigger a refresh
                },

                child: const Text('Refresh'),
              ),
              if (_isLoading) const CircularProgressIndicator(),
            ],
          ),
          const SizedBox(height: 8.0),
          ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              Product product = products[index];
              return Card(
                child: ListTile(
                  title: Text(product.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}'),
                      Text(product.description),
                    ],
                  ),
                  leading: product.images.isNotEmpty
                      ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(product.images.first),
                  )
                      : const SizedBox(width: 40, height: 40), // Placeholder for no images
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.update),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProductScreen(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          // Show a confirmation dialog
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Product'),
                                content: const Text('Are you sure you want to delete this product?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          // If the user confirmed the deletion, proceed with the deletion
                          if (confirmDelete == true) {
                            await _productService.deleteProduct(product.id); // Manually trigger a refresh after deletion
                          }
                        },
                      ),

                    ],
                  ),
                ),
              );
            },
          ),
        ],
      )
    );
  }
}
