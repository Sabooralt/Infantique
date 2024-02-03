import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/widgets/loadingManager.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';

class UpdateProductScreen extends StatefulWidget {
  final Product product;

  const UpdateProductScreen({super.key, required this.product});

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController sellerNameController;
  late TextEditingController reviewsIndexController;
  TextEditingController categoryController = TextEditingController();
  int currentImageIndex = 0;
  String successMessage = '';
  String errorMessage = '';
  List<File> selectedImages = [];
  bool hasImages = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product details
    titleController = TextEditingController(text: widget.product.title);
    descriptionController = TextEditingController(text: widget.product.description);
    priceController = TextEditingController(text: widget.product.price.toString());
    categoryController.text = allowedCategories.contains(widget.product.category)
        ? widget.product.category
        : allowedCategories.first;
    /*reviewsIndexController = TextEditingController(
      text: widget.product.reviews.isNotEmpty ? widget.product.reviews[index].toString() : '',
    );*/
  }
  Future<void> _pickImages() async {
    LoadingManager().showLoading(context); // Show loading overlay

    List<File> pickedImages = await _getImages();

    if (pickedImages.isNotEmpty) {
      try {
        List<String> uploadedImageUrls = await _uploadImages(pickedImages);

        setState(() {
          widget.product.images.addAll(uploadedImageUrls);
          selectedImages = pickedImages;
          successMessage = ''; // Clear success message when picking new images
          errorMessage = '';
          hasImages = true; // Clear error message when picking new images
        });
      } catch (error) {
        setState(() {
          errorMessage = 'Error uploading images';
        });
      } finally {
        LoadingManager().hideLoading(); // Hide loading overlay regardless of success or failure
      }
    } else {
      LoadingManager().hideLoading(); // Hide loading overlay if no images are picked
    }
  }





  Future<List<File>> _getImages() async {
    List<File> selectedImages = [];

    try {
      final picker = ImagePicker();
      List<XFile>? pickedImages = await picker.pickMultiImage();

      if (pickedImages != null) {
        selectedImages = pickedImages.map((image) => File(image.path)).toList();
      }
    } catch (e) {
      print('gg');
    }

    return selectedImages;
  }

  Future<List<String>> _uploadImages(List<File> images) async {
    List<String> imageUrls = [];

    try {
      for (File image in images) {
        String fileExtension = image.path.split('.').last;
        String fileName = '${const Uuid().v1()}.$fileExtension'; // Fix: Add the file extension to the filename
        firebase_storage.Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('product_images/$fileName');

        firebase_storage.UploadTask uploadTask = storageReference.putFile(image);
        await uploadTask.whenComplete(() => null);

        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      return imageUrls;
    } catch (error) {
      // Handle the error, show a message, etc.
      rethrow;
    }
  }



  void _deleteImage(int index) {
    setState(() {
      widget.product.images.removeAt(index);
      if (currentImageIndex >= widget.product.images.length) {
        currentImageIndex = widget.product.images.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              // Get the updated product details from the controllers
              Product updatedProduct = Product(
                id: widget.product.id,
                title: titleController.text,
                description: descriptionController.text,
                images: widget.product.images,
                price: double.parse(priceController.text),
               category: categoryController.text,
                reviews: widget.product.reviews,
                quantity: widget.product.quantity,
                sellerId: widget.product.sellerId,
                averageRating: widget.product.averageRating

              );

              List<String> originalImages = widget.product.images;
              List<String> updatedImages = updatedProduct.images;

              // Find images that were removed
              List<String> removedImages = originalImages.where((image) => !updatedImages.contains(image)).toList();

              // Delete removed images from Firebase Storage

              ProductService().deleteImagesFromStorage(removedImages);
              ProductService().updateProduct(updatedProduct);
              // Compare original and updated image URLs


              if (widget.product.images.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Product saved successfully!'),
                  duration: Duration(seconds: 2),
                ));
                // Navigate back to the admin panel or product list screen
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Product must have at least one image.'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display existing images (You can use your ImageSlider widget)
            if (widget.product.images.isNotEmpty)
                CarouselSlider.builder(
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index, realIndex) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              '${widget.product.images[index]}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                              fit: BoxFit.cover,
                              height: 150,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text('Error loading image'),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                            ),
                            child: Transform.scale(
                              scale: 0.8,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () => _deleteImage(index),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.6,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                  ),
                ),
            if (widget.product.images.isEmpty)
              const Text(
                'No images available.',
                style: TextStyle(fontSize: 16),
              ),


            const SizedBox(height: 20),
            // Button to pick new images
            ElevatedButton(
              onPressed: _pickImages,
              child: const Text('Pick Images'),
            ),
            const SizedBox(height: 20),
            // TextFields for updating product details
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: categoryController.text.isNotEmpty ? categoryController.text : null,
              items: allowedCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  categoryController.text = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 10),

            Container(
              width: 110,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: kprimaryColor,
              ),
              alignment: Alignment.center,
              child: const Text(
                "Reviews",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
