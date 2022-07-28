import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/constants.dart';

class CancelledPaymentScreen extends StatefulWidget {
  const CancelledPaymentScreen({Key? key}) : super(key: key);

  @override
  _CancelledPaymentScreenState createState() => _CancelledPaymentScreenState();
}

class _CancelledPaymentScreenState extends State<CancelledPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        leadingWidth: 30,
        title: const Text(
          "Payment Cancelled",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/cancelled.png",
              scale: 5,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Either you have cancelled payment or some error occured. Try Agian.",
                textAlign: TextAlign.center,
                style: GoogleFonts.martelSans(
                    fontWeight: FontWeight.w800, fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
