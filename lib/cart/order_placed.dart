import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/constants.dart';

class OrderPlacedScreen extends StatefulWidget {
  String orderId;
  OrderPlacedScreen({required this.orderId});

  @override
  _OrderPlacedScreenState createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: backIcon(context),
          elevation: 3,
          title: const Text(
            "Order Placed",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/check-mark.png",
                  scale: 5,
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Order Placed Successfully",
                    style: GoogleFonts.martelSans(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text("Order Id - " + widget.orderId.toString(),
                    style: GoogleFonts.martelSans(
                        fontSize: 20, fontWeight: FontWeight.w800))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
