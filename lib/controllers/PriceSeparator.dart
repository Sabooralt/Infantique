import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceSeparator extends StatelessWidget {
  final double price;
  final TextStyle textStyle;

  const PriceSeparator(
      {super.key, required this.price, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'ur_PK',
      symbol: 'Rs.',
    );

    String formattedPrice = formatter.format(price);

    // Remove trailing ".00" if present
    if (formattedPrice.endsWith('.00')) {
      formattedPrice = formattedPrice.substring(0, formattedPrice.length - 3);
    }

    return Text(
      formattedPrice,
      style: textStyle,
    );
  }
}
