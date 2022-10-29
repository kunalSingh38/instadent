import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';

class CancelledPaymentScreen extends StatefulWidget {
  const CancelledPaymentScreen({Key? key}) : super(key: key);

  @override
  _CancelledPaymentScreenState createState() => _CancelledPaymentScreenState();
}

class _CancelledPaymentScreenState extends State<CancelledPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
            (route) => false);
        //   Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                    (route) => false);
              },
              child: SizedBox(
                width: 80,
                child: Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.black,
                  size: 27,
                ),
              )),
          elevation: 3,
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
      ),
    );
  }
}
