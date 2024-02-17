import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/controllers/ProductFilter.dart';
import 'package:infantique/models/SortingFunctions.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/widgets/SupportFloatingActionButton.dart';
import 'package:infantique/screens/widgets/custom_app_bar.dart';
import 'package:infantique/screens/widgets/filterButtons.dart';
import 'package:infantique/widgets/product_card.dart';

class AllProductsScreen extends StatefulWidget {
  final List<Product>? initialProducts;

  static void navigateToAllProductsScreenAndFilterByCategory(
      BuildContext context, String category) async {
    List<Product> filteredProducts =
        await ProductFilter().getProductsByCategory(category);
    if (filteredProducts.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllProductsScreen(
            initialProducts: filteredProducts,
          ),
        ),
      );
    } else {
      // Show a message indicating no products are available for the selected category
      EasyLoading.showToast('No products available for $category');
    }
  }

  const AllProductsScreen({Key? key, this.initialProducts}) : super(key: key);

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  bool isSortedByPriceHighToLow = false;
  bool isSortedByPriceLowToHigh = false;
  List<Product> allProducts = [];
  bool isAscending = true;
  bool isLoading = false;
  SortingFunctions sortingFunctions = SortingFunctions();
  ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    if (widget.initialProducts != null) {
      allProducts = widget.initialProducts!;
    } else {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    try {
      EasyLoading.show(); // Show loading indicator

      List<Product> products = await productService.getProducts();
      setState(() {
        allProducts = products;
      });
    } catch (error) {
      print("Error fetching products: $error");
      // Handle the error (show a message, retry, etc.)
    } finally {
      EasyLoading
          .dismiss(); // Dismiss loading indicator regardless of success or failure
    }
  }

  void updateProducts(List<Product> updatedProducts) {
    print("Before setState: $allProducts");
    setState(() {
      allProducts = updatedProducts;
    });
    print("After setState: $allProducts");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Custom_Appbar(
        title: 'All Products',
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      filterProducts(
                        allProducts: allProducts,
                        updateUI: updateProducts,
                      ),
                      const SizedBox(height: 10),

                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,

                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 0.0,
                          mainAxisSpacing: 5,
                          mainAxisExtent: 264,
                        ),
                        itemCount: allProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: allProducts[index],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButtonWidget(),
     );
  }
}
