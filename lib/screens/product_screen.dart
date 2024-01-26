import 'package:flutter/material.dart';
import 'package:infantique/screens/widgets/product_widgets/add_to_cart.dart';
import 'package:infantique/screens/widgets/product_widgets/appbar.dart';
import 'package:infantique/screens/widgets/product_widgets/information.dart';
import 'package:infantique/screens/widgets/product_widgets/product_desc.dart';
import 'package:infantique/screens/widgets/product_widgets/information.dart';
import 'package:infantique/screens/widgets/product_widgets/category_details.dart';
import 'package:infantique/widgets/product_widgets/image_slider.dart';
import 'package:infantique/models/product.dart';

import '../constants.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int currentImage = 0;
  int currentColor = 0;
  int currentNumber = 1;

  static List<Color> staticColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
  ];


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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    duration: const Duration(milliseconds: 300),
                    width: currentImage == index ? 15 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 2),
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
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.only(
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
                            duration: const Duration(milliseconds: 300),
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: staticColors[index],  // Use the current index to get a different color
                              border: Border.all(
                                color: staticColors[index],  // Use the current index to get a different color
                              ),
                            ),
                            padding: currentColor == index ? const EdgeInsets.all(2) : null,
                            margin: const EdgeInsets.only(right: 15),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: staticColors[index],  // Use the current index to get a different color
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height:20),
                    ProductCat(categoryName: widget.product.category),
                    const SizedBox(height:10),
                    ProductDescription(text:widget.product.description ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

