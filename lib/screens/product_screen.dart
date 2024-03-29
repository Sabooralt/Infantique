import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infantique/models/cart_provider.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/models/reviews.dart';
import 'package:infantique/models/userDetails.dart';
import 'package:infantique/screens/widgets/SupportFloatingActionButton.dart';
import 'package:infantique/screens/widgets/custom_app_bar.dart';
import 'package:infantique/screens/widgets/product_widgets/category_details.dart';
import 'package:infantique/screens/widgets/product_widgets/information.dart';
import 'package:infantique/screens/widgets/product_widgets/product_desc.dart';
import 'package:infantique/screens/widgets/reviewForm.dart';
import 'package:infantique/widgets/product_widgets/image_slider.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../constants.dart';


class ProductScreen extends StatefulWidget {

  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductService _productService = ProductService();
  CartProvider cartProvider = CartProvider();
  int currentImage = 0;
  int currentColor = 0;
  int currentNumber = 1;
  Map<String, String> userDeliveryAddress = {};
  String? selectedDeliveryAddress;
  List<Review>? productReviews;



  @override
  void initState() {
    super.initState();
    fetchUserDeliveryAddresses();
    _loadProductReviews();
  }

  Future<List<Map<String, String>>> fetchUserDeliveryAddresses() async {
    try {

      // Get the current user's ID from Firebase Authentication
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Check if the user is authenticated
      if (userId != null) {

        // Reference to the "users" collection
        CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

        // Reference to the user's document
        DocumentReference userDocument = usersCollection.doc(userId);

        // Reference to the "delivery_addresses" subcollection
        CollectionReference deliveryAddressesCollection =
        userDocument.collection('delivery_addresses');

        // Get all documents in the "delivery_addresses" subcollection
        QuerySnapshot deliveryAddressesSnapshot =
        await deliveryAddressesCollection.get();

        // Check if there are any documents in the subcollection
        if (deliveryAddressesSnapshot.docs.isNotEmpty) {

          // Extract the information for each delivery address
          List<Map<String, String>> addresses = deliveryAddressesSnapshot.docs
              .map((DocumentSnapshot addressSnapshot) {
            String name = addressSnapshot['name'] ?? '';
            String address = addressSnapshot['address'] ?? '';

            return {'name': name, 'address': address};
          }).toList();

          // Return the list of addresses
          return addresses;
        } else {
          // No documents found in the subcollection
          return [];
        }
      } else {

        throw Exception('User is not authenticated.');
      }
    } catch (e) {
      throw Exception('Error fetching user addresses. Please try again.');
    }
  }


  static List<Color> staticColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];



  Future<void> _loadProductReviews() async {
    try {
      List<Review> reviews = await _productService.getProductReviews(widget.product.id);
      setState(() {
        productReviews = reviews;
      });
    } catch (e) {
      // Handle the error as needed
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Custom_Appbar(
        title: widget.product.title,
      ),
      persistentFooterButtons: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  CartProvider cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.addToCart(widget.product, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.title} added to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Vx.indigo700, // text color
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                child: const Text('Add to Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),
            ),
            const SizedBox(width: 8), // Add some space between the buttons
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle "Buy Now" button press
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: kprimaryColor, // text color
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),

                  ),
                ),
                child: const Text('Buy Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),
            ),
          ],
        ),
      ],

      backgroundColor: kcontentColor,


      body: SafeArea(
        child: ListView(
          children: [
            ImageSlider(
              onChange: (index) {
                setState(() {
                  currentImage = index;
                });
              },
              currentImage: currentImage,
              images: widget.product.images,
            ),
            Container(
              width: double.infinity,
              decoration:  const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                color: Colors.white60,
              ),
              padding:  const EdgeInsets.only(
                left: 20,
                top: 20,
                right: 20,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfo(product: widget.product),
                  const SizedBox(height: 20),
                  const Text(
                    "Color",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(
                      staticColors.length,
                          (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            currentColor = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration:  const Duration(milliseconds: 300),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: staticColors[index],
                            border: Border.all(
                              color: staticColors[index],
                            ),
                          ),
                          padding: currentColor == index
                              ?  const EdgeInsets.all(2)
                              : null,
                          margin:  const EdgeInsets.only(right: 15),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: staticColors[index],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProductCat(categoryName: widget.product.category),
                  const SizedBox(height: 10),
                  ProductDescription(text: widget.product.description),

                  const SizedBox(height: 40,),
                  // Ratings & Reviews Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ratings & Reviews',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        const SizedBox(height: 10),
                        if (productReviews != null && productReviews!.isNotEmpty)
                          Column(
                            children: productReviews!.map((review) {
                              return FutureBuilder<UserDetails>(
                                future: fetchUserDetails(review.userId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); // or a loading indicator
                                  } else if (snapshot.hasError) {
                                    return Text('Error loading user details: ${snapshot.error}');
                                  } else {
                                    UserDetails userDetails = snapshot.data!;


                                    return ListTile(
                                      title: Text(
                                        userDetails.username,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Comment: ${review.comment}'),
                                          RatingBar.builder(
                                            initialRating: review.rating.toDouble(), // Convert int to double
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: false,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            ignoreGestures: true,
                                            onRatingUpdate: (rating) {}, // Provide a dummy function
                                          ),
                                        ],
                                      ),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(userDetails.userPicUrl),
                                      ),
                                    );
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20,),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showReviewForm(context, widget.product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Vx.indigo700, // text color
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add,
                                  color: Colors.white,

                                ), // Add your desired icon
                                SizedBox(width: 8), // Adjust the spacing between the icon and text
                                Text('Add a Review',

                                  style:
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                          ),
                        ),
                      ],
                    ),
                  ),

                  // Service
                  const SizedBox(height: 20,),
                  Container(
                    padding: const EdgeInsets.all(16.0), // Adjust padding as needed
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      // Add a border for visual separation
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: Add border radius for rounded corners
                    ),
                    child: Column(

                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service', // Add your desired heading
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        _buildServiceOption("14 days free & easy return", Ionicons.checkmark_circle, Colors.green),
                        const SizedBox(height: 8.0), // Add vertical space between options
                        _buildServiceOption("Warranty not available", Ionicons.warning, Colors.black),
                      ],
                    ),
                  ),

                  Container(

                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Addresses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FutureBuilder<List<Map<String, String>>>(
                          future: fetchUserDeliveryAddresses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              List<Map<String, String>> addresses = snapshot.data!;

                              if (addresses.isNotEmpty) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: addresses.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        // Handle the onTap event for the selected address
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.purple, width: 2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name: ${addresses[index]['name']}',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              'Address: ${addresses[index]['address']}',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Text('No delivery addresses available.');
                              }
                            } else {
                              return const Text('No delivery addresses available.');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonWidget(),
    );


  }



  Widget _buildServiceOption(String text, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        const SizedBox(width: 8.0),
        Text(text),
      ],
    );
  }


  _showReviewForm(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ReviewForm(
          onSubmit: (review) {
            // Call a function to associate the product ID with the review
            _reviewFormSubmitHandler(review, product);

            // Close the review form dialog
            Navigator.pop(context);

            // Show a success message using SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                content: Text('Review submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          productId: product.id, // Pass the productId to ReviewForm
        );
      },
    );
  }

  _reviewFormSubmitHandler(Review review, Product product) {
    // Handle the submitted review
    setState(() {
      product.reviews.add(review);
    });

  }



}

