import 'package:infantique/models/product.dart';

class SortingFunctions {
  void sortByPriceLowToHigh(List<Product> products) {
    print('Sorting low to high');
    products.sort((a, b) => a.price.compareTo(b.price));
    print(products);
  }

  void sortByPriceHighToLow(List<Product> products) {
    print('Sorting high to low');
    products.sort((a, b) => b.price.compareTo(a.price));
    print(products);
  }

// Add more sorting functions as needed
}