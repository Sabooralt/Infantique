

import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infantique/admin_panel/UpdateProductScreen.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/controllers/seller_controller.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/widgets/loadingManager.dart';
import 'package:uuid/uuid.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final ProductService productService = ProductService();
  final SellerAuthController sellerAuthController = SellerAuthController();



  List<File> _images = [];

  String successMessage = '';
  String errorMessage = '';

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final pickedImages = await _getImages();
                setState(() {
                  _images = pickedImages;
                  successMessage = ''; // Clear success message when picking new images
                  errorMessage = ''; // Clear error message when picking new images
                });
                            },
              child: const Text('Pick Images'),
            ),
            _images.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 8.0), // Add padding on top
              child: CarouselSlider.builder(
                itemCount: _images.length,
                itemBuilder: (context, index, realIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add horizontal padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius
                      child: Image.file(
                        _images[index], // Assuming '_images' is a list of File
                        fit: BoxFit.cover,
                        height: 150, // Adjust the height as needed
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.6,
                  autoPlay: false,
                ),
              ),
            )
                : const SizedBox(height: 0),

            const SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Product Price'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: categoryController.text.isNotEmpty ? categoryController.text : null,
              items: allowedCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                // Update the categoryController when a category is selected
                setState(() {
                  categoryController.text = value ?? '';
                });
              },
              decoration: const InputDecoration(labelText: 'Product Category'),
            ),
            const SizedBox(height: 16.0),



            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                String? sellerId = await sellerAuthController.getCurrentSellerId();

                if (sellerId != null) {
                  _addProduct(sellerId);
                } else {
                  print('No authenticated seller.');
                  // Handle the case when there is no authenticated seller
                }
              },
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 16.0),
            Text(successMessage, style: const TextStyle(color: Colors.green)),
            Text(errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const Center(
          child: Text(
            'Add Product',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<List<File>> _getImages() async {
    List<File> selectedImages = [];

    try {
      final picker = ImagePicker();


      List<XFile>? pickedImages = await picker.pickMultiImage();

      selectedImages = pickedImages.map((image) => File(image.path)).toList();
        } on PlatformException catch (e) {
      print("Error picking images: $e");
    }

    return selectedImages;
  }



  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    try {
      for (File image in images) {
        String fileName = const Uuid().v1(); // Generate a unique filename
        String fileExtension = image.path.split('.').last; // Get the original file extension

        String filePath = 'product_images/$fileName.$fileExtension';

        firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child(filePath);

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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _addProduct(String sellerId) async {
    String title = nameController.text.trim();
    String description = descriptionController.text.trim();
    String category = categoryController.text.trim();
    int quantity = 0;

    LoadingManager().showLoading(context);

    if (title.isEmpty || description.isEmpty || category.isEmpty) {
      setState(() {
        errorMessage = 'Please fill in all fields.';
        successMessage = '';
        LoadingManager().hideLoading();
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
          reviews: [],
          quantity: quantity,
          sellerId: sellerId,
          averageRating: 0.0
        );

        await productService.addProduct(newProduct, sellerId);

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
    } finally {
      LoadingManager().hideLoading();
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

