import 'package:flutter/material.dart';
import 'package:infantique/models/SortingFunctions.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/widgets/custom_app_bar.dart';
import 'package:infantique/screens/widgets/filterButtons.dart';
import 'package:infantique/widgets/product_card.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  bool isSortedByPriceHighToLow = false;
  bool isSortedByPriceLowToHigh = false;
  List<Product> allProducts = [];
  bool isAscending = true;
  SortingFunctions sortingFunctions = SortingFunctions();
  ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Custom_Appbar( title: Text(''),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                FilterButtons(
                  sortingFunctions: sortingFunctions,
                  onCategoryPressed: () {
                    // Handle category button press
                  },
                  onBrandPressed: () {
                    // Handle brand button press
                  }, products: allProducts,
                  onSortingChanged: () {
                    setState(() {
                      // Call the sorting functions here
                      if (isSortedByPriceHighToLow) {
                        sortingFunctions.sortByPriceHighToLow(allProducts);
                      } else if (isSortedByPriceLowToHigh) {
                        sortingFunctions.sortByPriceLowToHigh(allProducts);
                      }
                    });
                  },
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Product>>(
                  future: productService.getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Loading indicator while fetching data
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Error handling
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // Products are fetched successfully
                      allProducts = snapshot.data ?? [];


                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 0.75,
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: allProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: allProducts[index]);
                        },
                      );
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
