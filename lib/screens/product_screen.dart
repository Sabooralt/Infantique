import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:infantique/models/userDetails.dart';
import 'package:infantique/screens/widgets/product_widgets/add_to_cart.dart';
import 'package:infantique/screens/widgets/product_widgets/appbar.dart';
import 'package:infantique/screens/widgets/product_widgets/information.dart';
import 'package:infantique/screens/widgets/product_widgets/product_desc.dart';
import 'package:infantique/screens/widgets/product_widgets/category_details.dart';
import 'package:infantique/screens/widgets/reviewForm.dart';
import 'package:infantique/widgets/product_widgets/image_slider.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/models/reviews.dart';

import '../constants.dart';


class ProductScreen extends StatefulWidget {

  final Product product;

  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductService _productService = ProductService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentImage = 0;
  int currentColor = 0;
  int currentNumber = 1;
  Map<String, String> userDeliveryAddress = {};
  String? selectedDeliveryAddress;
  List<Review>? productReviews;
  double averageRating = 4.5;
  int totalReviews = 15;
  late User? _currentUser;
  late String _selectedAddress;
  late TextEditingController _newAddressController;

  @override
  void initState() {
    super.initState();
    _newAddressController = TextEditingController();
    _selectedAddress = '';
    _initializeCurrentUser();
    fetchUserDeliveryAddress().then((address) {
      setState(() {
        userDeliveryAddress = address;
      });
    }).catchError((error) {
      // Handle error if needed
      print('Error fetching user delivery address: $error');
    });
    _loadProductReviews();
  }

  Future<Map<String, String>> fetchUserDeliveryAddress() async {
    try {
      print('Fetching user delivery address...');

      // Get the current user's ID from Firebase Authentication
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      // Check if the user is authenticated
      if (userId != null) {
        print('User ID: $userId');

        // Reference to the "users" collection
        CollectionReference usersCollection = FirebaseFirestore.instance
            .collection('users');

        // Reference to the user's document
        DocumentReference userDocument = usersCollection.doc(userId);

        // Reference to the "delivery_addresses" subcollection
        CollectionReference deliveryAddressesCollection = userDocument
            .collection('delivery_addresses');

        // Get the documents in the "delivery_addresses" subcollection
        QuerySnapshot deliveryAddressesSnapshot = await deliveryAddressesCollection
            .get();

        // Check if there are any documents in the subcollection
        if (deliveryAddressesSnapshot.docs.isNotEmpty) {
          print('Delivery address found.');

          // Use the first document in the subcollection
          DocumentSnapshot deliveryAddressSnapshot = deliveryAddressesSnapshot
              .docs.first;

          // Extract the name and address fields
          String name = deliveryAddressSnapshot['name'] ?? '';
          String address = deliveryAddressSnapshot['address'] ?? '';

          // Return the name and address as a map
          Map<String, String> deliveryAddress = {
            'name': name,
            'address': address
          };
          print('Delivery address: $deliveryAddress');

          return deliveryAddress;
        } else {
          // No documents found in the subcollection
          print('No delivery address found for the user.');
          throw Exception('No delivery address found for the user.');
        }
      } else {
        // User is not authenticated
        print('User is not authenticated.');
        throw Exception('User is not authenticated.');
      }
    } catch (e) {
      print('Error fetching user address: $e');
      // Handle the error as needed
      throw Exception('Error fetching user address. Please try again.');
    }
  }


  Future<void> _initializeCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      // Fetch user addresses from Firestore
      CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

      DocumentSnapshot userDocument =
      await usersCollection.doc(_currentUser!.uid).get();

      if (userDocument.exists) {
        // Assuming "delivery_addresses" is a subcollection
        CollectionReference deliveryAddresses =
        usersCollection.doc(_currentUser!.uid).collection('delivery_addresses');

        QuerySnapshot addressesSnapshot = await deliveryAddresses.get();

        if (addressesSnapshot.docs.isNotEmpty) {
          // Assuming each user has only one address, you can modify this part based on your data structure
          _selectedAddress = addressesSnapshot.docs[0]['address'];
          print('Success');
        } else {
          _selectedAddress =
          'No address found'; // Default value if no address is found
        }
      } else {
        _selectedAddress =
        'No user document found'; // Handle the case where the user document doesn't exist
      }
    }
  }


  static List<Color> staticColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];


  void _updateUserAddress(String newAddress) async {
    try {
      if (_currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .set({'address': newAddress}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user address: $e');
    }
  }

  Future<void> _loadProductReviews() async {
    try {
      List<Review> reviews = await _productService.getProductReviews(widget.product.id);
      setState(() {
        productReviews = reviews;
      });
      print('Reviews fetched Successfully');
    } catch (e) {
      print('Error loading product reviews: $e');
      // Handle the error as needed
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcontentColor,
      floatingActionButton: AddToCart(
        currentNumber: currentNumber,
        onAdd: () {
          setState(() {
            currentNumber++;
          });
        },
        onRemove: () {
          if (currentNumber != 1) {
            setState(() {
              currentNumber--;
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: ListView(
          children: [
            const ProductAppBar(),
            ImageSlider(
              onChange: (index) {
                setState(() {
                  currentImage = index;
                });
              },
              currentImage: currentImage,
              images: widget.product.images,
            ),
             const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) => AnimatedContainer(
                  duration:  const Duration(milliseconds: 300),
                  width: currentImage == index ? 15 : 8,
                  height: 8,
                  margin:  const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                    ),
                    color: currentImage == index
                        ? Colors.black
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
             const SizedBox(height: 20),
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
                    decoration: const BoxDecoration(
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
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showReviewForm(context, widget.product),
                            child: const Text('Add a Review'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (productReviews != null && productReviews!.isNotEmpty)
                          Column(
                            children: productReviews!.map((review) {
                              return FutureBuilder<UserDetails>(
                                future: fetchUserDetails(review.userId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // or a loading indicator
                                  } else if (snapshot.hasError) {
                                    return Text('Error loading user details: ${snapshot.error}');
                                  } else {
                                    UserDetails userDetails = snapshot.data!;

                                    // Display ListTile with user details and review comment
                                    return ListTile(
                                      title: Text(
                                        '${userDetails.username}',
                                        style: TextStyle(
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
                      ],
                    ),
                  ),

                  // Service
                  Container(
                    width: 200,
                    color: Colors.white,
                    padding:  const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    margin:  const EdgeInsets.only(top: 10),
                    child:  const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Add more details about service and delivery...
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding:  const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 20),
                    margin:  const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text(
                          'Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _showAddressDialog(context);
                          },
                          // Display the user's delivery address
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.purple, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding:  const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start,
                              children: [
                                 const Text('Delivery Address',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '$selectedDeliveryAddress',
                                ),
                              ],
                            ),
                          ),
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
    );


  }

  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  const Text('Select Delivery Address'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  // Handle selecting current location
                  Navigator.pop(context);
                  _updateUserAddressWithCurrentLocation();
                },
                child:  const Text('Use Current Location'),
              ),
              TextButton(
                onPressed: () {
                  // Handle choosing existing location
                  Navigator.pop(context);
                  _showExistingAddressesDialog(context);
                },
                child:  const Text('Choose Existing Location'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExistingAddressesDialog(BuildContext context) async {
    try {
      // Fetch the user's delivery addresses
      Map<String, String> deliveryAddresses = await fetchUserDeliveryAddress();

      // Check if there are any addresses to display
      if (deliveryAddresses.isEmpty) {
        // Handle the case where there are no existing addresses
        print('No existing addresses found.');
        return;
      }

      // Show a dialog with a list of existing addresses
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title:  const Text('Select Existing Address'),
            content: SingleChildScrollView(
              child: Column(
                children: deliveryAddresses.entries.map((entry) {
                  String addressId = entry.key;
                  String address = entry.value;

                  return ListTile(
                    title: Text(address),
                    onTap: () {
                      // Handle the selected existing address
                      _handleExistingAddressSelection(address);

                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Close the dialog without selecting any address
                  Navigator.of(context).pop();
                },
                child:  const Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle errors, such as fetching addresses or other exceptions
      print('Error showing existing addresses dialog: $e');
    }
  }

  void _handleExistingAddressSelection(String selectedAddress) {
    // Update the state with the selected address
    setState(() {
      selectedDeliveryAddress = selectedAddress;
    });

    // Perform any other actions based on the selected address
    print('Selected address: $selectedAddress');
  }


  void _updateUserAddressWithCurrentLocation() {
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

    // Additional logic if needed, e.g., saving the review to Firestore
    // saveReviewToFirestore(review);
  }



}

