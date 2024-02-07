import 'package:flutter/material.dart';
import 'package:infantique/controllers/seller_controller.dart';
import 'package:ionicons/ionicons.dart';

class Sellers extends StatefulWidget {
  @override
  _SellersState createState() => _SellersState();
}

class _SellersState extends State<Sellers> {
  SellerAuthController _sellerController = SellerAuthController();
  List<Map<String, dynamic>> _sellers = [];
  int sellersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    List<Map<String, dynamic>> sellers = await _sellerController.fetchSellers();
    setState(() {
      _sellers = sellers;
      sellersCount = _sellers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Sellers Count: $sellersCount',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _sellers.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> seller = _sellers[index];

              return ListTile(
                title: Text(seller['name']),
                // Assuming 'name' is a field in your sellers collection
                subtitle: Text(seller['email']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.block),
                      onPressed: () {},
                    ),
                    // Replace 'icon1' with the first icon you want to display
                    SizedBox(width: 8),
                    // Adjust the width as needed
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {},
                    ),
                    // Replace 'icon2' with the second icon you want to display
                  ],
                ),

                // Assuming 'email' is a field in your sellers collection
                // Add more fields as needed
              );
            },
          ),
        ),
      ],
    );
  }
}
