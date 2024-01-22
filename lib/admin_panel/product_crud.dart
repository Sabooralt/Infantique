import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:infantique/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:infantique/widgets/loadingManager.dart';


class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  final ProductService productService = ProductService();

  List<File> _images = [];

  String successMessage = '';
  String errorMessage = '';

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
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
            ElevatedButton(
              onPressed: () async {
                final pickedImages = await _getImages();
                if (pickedImages != null) {
                  setState(() {
                    _images = pickedImages;
                    successMessage = ''; // Clear success message when picking new images
                    errorMessage = ''; // Clear error message when picking new images
                  });
                }
              },
              child: Text('Pick Images'),
            ),
            _images.isNotEmpty
                ? CarouselSlider.builder(
              itemCount: _images.length,
              itemBuilder: (context, index, realIndex) {
                return Image.network(
                  _images[index].path, // Assuming '_images' is a list of File
                  fit: BoxFit.cover,
                  height: 150,
                );
              },
              options: CarouselOptions(
                aspectRatio: 16 / 9,
                viewportFraction: 0.6,
                autoPlay: false,
              ),
            )
                : SizedBox(height: 0),

            SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
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
            Text(successMessage, style: TextStyle(color: Colors.green)),
            Text(errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16.0),
            RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async {
                await _refreshProducts();
              },
              child: ProductList(
                productService: productService,
                refreshProducts: _refreshProducts,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<File>> _getImages() async {
    List<File> selectedImages = [];

    try {
      final picker = ImagePicker();

      if (kIsWeb) {
        // Use web-specific code (e.g., image_picker_web) for Flutter web
        // Example: https://pub.dev/packages/image_picker_web
        // Note: Replace the following line with the actual web implementation
        throw UnimplementedError('Web implementation not provided');
      } else {
        List<XFile>? pickedImages = await picker.pickMultiImage();

        if (pickedImages != null) {
          selectedImages = pickedImages.map((image) => File(image.path)).toList();
        }
      }
    } on PlatformException catch (e) {
      print("Error picking images: $e");
    }

    return selectedImages;
  }



  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    try {
      for (File image in images) {
        firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance
            .ref()
            .child('product_images/${DateTime.now().millisecondsSinceEpoch}');

        firebase_storage.UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);

        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      setState(() {
        _isLoading = true;
      });

      return imageUrls;
    } catch (error) {
      print(error);
      throw 'Error uploading images: $error';
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _addProduct() async {
    String title = nameController.text.trim();
    String description = descriptionController.text.trim();
    String category = categoryController.text.trim();

    if (title.isEmpty || description.isEmpty || category.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
        successMessage = '';
      });
      return;
    }

    double price = double.tryParse(priceController.text.trim()) ?? 0.0;

    try {
      if (_images.isNotEmpty) {
        List<String> imagePaths = await _uploadImages(_images);

        Product newProduct = Product(
          id: '',
          title: title,
          description: description,
          images: imagePaths,
          price: price,
          category: category,
        );

        await productService.addProduct(newProduct);

        setState(() {
          successMessage = 'Product added successfully!';
          errorMessage = '';
          _clearFields();
        });
      } else {
        setState(() {
          errorMessage = 'Please pick at least one image.';
          successMessage = '';
          _isLoading = true;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error adding product: $error';
        successMessage = '';
      });
      _refreshIndicatorKey.currentState?.show();
    }finally{
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    categoryController.clear();
    setState(() {
      _images = [];
    });
  }

  Future<void> _refreshProducts() async {
    // Implement your logic to refresh the product list
    setState(() {});
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
                ],
              ),
              SizedBox(height: 8.0),
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
                          ? Container(
                        width: 50,
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.images.length,
                          itemBuilder: (context, imageIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                NetworkImage(product.images[imageIndex]),
                              ),
                            );
                          },
                        ),
                      )
                          : SizedBox(width: 50, height: 50),
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