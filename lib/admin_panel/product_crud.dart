import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infantique/models/product.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final ProductService productService = ProductService();
  final Product myProduct = Product(
    id: '',
    title: '',
    description: '',
    category: '',
    image: '',
    price: 0,
  );

  String successMessage = '';
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Product Description'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: imageController,
              decoration: InputDecoration(labelText: 'Product Image URL'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // Allow only numeric input
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Product Category'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _addProduct();
              },
              child: Text('Add Product'),
            ),
            SizedBox(height: 16.0),
            // Display success or error message
            Text(successMessage, style: TextStyle(color: Colors.green)),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16.0),
            // Display the list of products
            Expanded(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  await _refreshProducts();
                },
                child: ProductList(
                  productService: productService,
                  refreshProducts: _refreshProducts,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    String title = nameController.text.trim();
    String description = descriptionController.text.trim();
    String image = imageController.text.trim();
    String category = categoryController.text.trim();

    if (title.isEmpty || description.isEmpty || image.isEmpty ||
        category.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
        successMessage = '';
      });
      return;
    }

    double price = double.tryParse(priceController.text.trim()) ?? 0.0;

    Product newProduct = Product(
      id: '',
      // This will be assigned by Firestore
      title: title,
      description: description,
      image: image,
      price: price,
      category: category,
    );

    try {
      await productService.addProduct(newProduct);
      setState(() {
        successMessage = 'Product added successfully!';
        errorMessage = '';
      });

      // Clear the text fields after adding a product
      nameController.clear();
      descriptionController.clear();
      imageController.clear();
      priceController.clear();
      categoryController.clear();
    } catch (error) {
      setState(() {
        errorMessage = 'Error adding product: $error';
        successMessage = '';
      });
      _refreshIndicatorKey.currentState?.show();
    }
  }


  // Manually trigger a refresh


  Future<void> _refreshProducts() async {
    // Implement your logic to refresh the product list
    setState(() {
      // Manually trigger a refresh by rebuilding the widget
    });
  }
}


class ProductList extends StatelessWidget {
  final ProductService productService;
  final Function refreshProducts;

  ProductList({required this.productService, required this.refreshProducts});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
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
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      refreshProducts(); // Manually trigger a refresh
                    },
                    child: Text('Refresh'),
                  ),
                  // Add your loading screen widget here
                ],
              ),
              SizedBox(height: 8.0),
              // Display the list of products
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
                      leading: product.image.isNotEmpty
                          ? Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(product.image),
                          ),
                        ),
                      )
                          : SizedBox(width: 50, height: 50), // Placeholder for image if empty
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.update),
                            onPressed: () {
                              // Implement your update logic here
                              // You can navigate to a new screen or show a dialog for editing
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
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
