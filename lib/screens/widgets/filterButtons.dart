import 'package:flutter/material.dart';
import 'package:infantique/models/SortingFunctions.dart';
import 'package:infantique/models/product.dart';
import 'package:ionicons/ionicons.dart';

class FilterButtons extends StatelessWidget {
  final SortingFunctions sortingFunctions;
  final Function() onSortingChanged;
  final Function() onCategoryPressed;
  final Function() onBrandPressed;
  final List<Product> products;

  const FilterButtons({
    required this.onSortingChanged,
    required this.sortingFunctions,
    required this.onCategoryPressed,
    required this.onBrandPressed,
    required this.products,
  });

  @override
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
                    padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: onBrandPressed,
                  child: Text(
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
                    padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => _showSortingOptions(context),
                  icon: Icon(
                    Ionicons.funnel_outline,
                    size: 15,
                    color: Colors.black,
                  ),
                  label: Text(
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
                    padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: onCategoryPressed,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
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

  void _showSortingOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Price High To Low'),
                onTap: () {
                  Navigator.pop(context);
                  sortingFunctions.sortByPriceHighToLow(products);
                  onSortingChanged();
                },
              ),
              ListTile(
                title: Text('Price Low To High'),
                onTap: () {
                  Navigator.pop(context);

                  sortingFunctions.sortByPriceLowToHigh(products);
                  onSortingChanged();
                },
              ),
              ListTile(
                title: Text('Top Sales'),
                onTap: () {
                  Navigator.pop(context);
                  // You can add more sorting options or customize this section
                },
              ),
            ],
          ),
        );
      },
    );
  }

}
