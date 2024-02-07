import 'package:flutter/material.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/allProducts.dart';
import 'package:infantique/screens/widgets/SupportFloatingActionButton.dart';
import 'package:infantique/widgets/Email_Verifaction_Widget.dart';
import 'package:infantique/widgets/categories.dart';
import 'package:infantique/widgets/home_slider.dart';
import 'package:infantique/widgets/product_card.dart';
import 'package:infantique/widgets/search_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ProductService productService = ProductService();
  int currentSlide = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kscaffoldColor,
      body: SafeArea(

        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const SearchField(),
                const SizedBox(height: 20),
                HomeSlider(
                  onChange: (value) {
                    setState(() {
                      currentSlide = value;
                    });
                  },
                  currentSlide: currentSlide,
                ),
                EmailVerificationSnackbar(),
                const SizedBox(height: 20),
                const Categories(),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllProductsScreen(),
                          ),
                        );
                      },
                      child: const Text("See all"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Product>>(
                  future: productService.getRandomProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Loading indicator while fetching data
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Error handling
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Products are fetched successfully
                      List<Product> products = snapshot.data ?? [];

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 5,
                          mainAxisExtent: 264,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: products[index],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButtonWidget(),
    );
  }
}
