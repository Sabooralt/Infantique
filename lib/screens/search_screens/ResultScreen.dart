import 'package:flutter/material.dart';
import 'package:infantique/models/RatingManager.dart';
import 'package:infantique/models/product.dart';
import 'package:infantique/screens/widgets/custom_app_bar.dart';
import 'package:infantique/widgets/product_card.dart';

class ResultsScreen extends StatefulWidget {
  final String query;

  ResultsScreen({required this.query});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  ProductService productService = ProductService();
  List<Product> searchResults = [];

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  void _fetchResults() async {
    try {
      List<Product> results = await productService.getSearchedProducts(
        searchQuery: widget.query,
      );

      setState(() {
        searchResults = results;
      });

      // Check if no products are found
      if (results.isEmpty) {
        // Show an error message on the UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('No products found. Try searching for something else.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error fetching results: $e');
      // Handle the error as needed, e.g., show an error message on the UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching results. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Custom_Appbar(title: Text('Search Results For : $searchResults')),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.75,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: searchResults[index],
                  );
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}
