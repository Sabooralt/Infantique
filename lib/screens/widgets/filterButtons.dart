import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:infantique/constants.dart';
import 'package:infantique/controllers/ProductFilter.dart';
import 'package:infantique/models/product.dart';
import 'package:ionicons/ionicons.dart';

class filterProducts extends StatefulWidget {
  final List<Product> allProducts;
  final void Function(List<Product>) updateUI;

  filterProducts({
    required this.allProducts,
    required this.updateUI,


  });

  @override
  State<filterProducts> createState() => _filterProductsState();
}

class _filterProductsState extends State<filterProducts> {
  List<Product> allProducts = [];
  ProductService productService = ProductService();
  String? selectedCategory;


  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: [
              // Brand Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {

                  },
                  child: const Text(
                    'Brand',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Sort By Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => _showSortingOptions(context),
                  icon: const Icon(
                    Ionicons.funnel_outline,
                    size: 15,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              // Category Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    _showCategoryOptions(context);
                  },
                  child: const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    _resetSelection();
                    EasyLoading.showToast('Filters reset successfully');
                  },
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCategoryOptions(BuildContext context) async {
    List<String> categories = allowedCategories;


    if (categories.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (String category in categories)
                  ListTile(
                    title: Row(
                      children: [
                        Text(category),
                        SizedBox(
                          width: 5,
                        ),
                        if (category == selectedCategory)
                          Icon(Icons.check, color: kprimaryColor),
                      ],
                    ),
                    onTap: () async {
                      List<Product> filteredProducts =
                      await ProductFilter().getProductsByCategory(category);
                      if (filteredProducts.isNotEmpty) {
                        // Call the callback function to update the products in AllProductsScreen
                        widget.updateUI(filteredProducts);
                      } else {
                        // Show a message indicating no products are available for the selected category
                        EasyLoading.showToast(
                            'No products available for $category');
                      }

                      // Update selectedCategory when a category is tapped
                      setState(() {
                        selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          );
        },
      );
    } else {
      EasyLoading.showToast('No categories available');
    }
  }


  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: const Text('Price High To Low'),
                  onTap: () async {
                    List<Product> sortedProducts =
                        await productService.getProducts(
                      orderBy: 'price',
                      descending: true,
                    );

                    widget.updateUI(sortedProducts);
                    Navigator.pop(context);
                    EasyLoading.showToast('Products filtered by High To Low!',
                        duration: Duration(milliseconds: 800));
                  }),
              ListTile(
                title: const Text('Price Low To High'),
                onTap: () async {
                  List<Product> sortedProducts =
                      await productService.getProducts(
                    orderBy: 'price',
                    descending: false,
                  );
                  widget.updateUI(sortedProducts);
                  Navigator.pop(context);
                  EasyLoading.showToast('Products filtered by Low To High!',
                      duration: Duration(milliseconds: 800));
                },
              ),
              ListTile(
                title: const Text('Top Sales'),
                onTap: () {
                  // ... implement other sorting logic or filtering ...
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetSelection() {
    setState(() {
      selectedCategory = null;
    });

    // Reset other data or UI elements as needed

    // Reset other filters or settings (modify this part based on your specific logic)
    List<Product> originalProducts = widget.allProducts;
    widget.updateUI(originalProducts);
  }
}