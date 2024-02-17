import 'package:flutter/material.dart';
import 'package:infantique/screens/SupportPage.dart';
import 'package:ionicons/ionicons.dart';
import 'package:velocity_x/velocity_x.dart';


class FloatingActionButtonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        VxToast.show(context, msg: "Hello from vx");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupportScreen()),
        );
      },
      backgroundColor: Vx.pink400, // Change the background color
      elevation: 8.0,
      child: Icon(

          Ionicons.headset_outline,
        color: Colors.white,

      ), // Replace with your desired icon
    );
  }
}