
import 'package:flutter/material.dart';
import 'package:infantique/admin_panel/UpdateProductScreen.dart';
import 'package:infantique/models/product.dart';


class ProductsContent extends StatelessWidget {
  final ProductService productService;
  final Function refreshProducts;

  ProductsContent({required this.productService, required this.refreshProducts});


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Product> products = snapshot.data ?? [];
          int productCount = products.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Product List ($productCount)',
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      refreshProducts(); // Manually trigger a refresh
                    },
                    child: const Text('Refresh'),
                  ),
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
                              await productService.deleteProduct(product.id);
                              refreshProducts(); // Manually trigger a refresh after deletion
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }
}
