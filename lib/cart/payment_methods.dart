// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/cart/cancelled_payment.dart';
import 'package:instadent/cart/order_placed.dart';
import 'package:instadent/category/all_categories.dart';
import 'package:instadent/constants.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMenthosScreen extends StatefulWidget {
  String totalPayment;
  bool retry;
  String orderId;
  PaymentMenthosScreen(
      {required this.totalPayment, required this.retry, required this.orderId});
  @override
  _PaymentMenthosScreenState createState() => _PaymentMenthosScreenState();
}

class _PaymentMenthosScreenState extends State<PaymentMenthosScreen> {
  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay _razorpay;
  bool placingOrder = false;
  String email = "";
  String phoneNumber = "";
  bool isLoading = true;
  List cartData = [];
  bool outofstock = false;

  getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      CartAPI().cartData().then((value) {
        setState(() {
          isLoading = false;
        });
        if (value.isNotEmpty) {
          if (value['items'].length > 0) {
            List temp = value['items'];
            temp.forEach((element) {
              if (element['is_stock'] == 0) {
                setState(() {
                  outofstock = true;
                });
              }
            });
          }
        }
        print(outofstock.toString() + " ---items are out of stock");
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    LoginAPI().getCustomerDetails().then((value) {
      setState(() {
        email = value["email"].toString();
        phoneNumber = value["mobile"].toString();
      });
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      if (widget.retry) {
        setState(() {
          placingOrder = true;
        });
        CartAPI().placePendingOrder(widget.orderId).then((value) {
          if (value['ErrorCode'] == 0) {
            openCheckout(value['Response']['razorpay_order']['id'].toString());
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Order place failed. Try again."),
              ),
            );
          }
        });
      }
      getData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout(String orderId) async {
    var options = {
      // 'key': 'rzp_test_rmwv0ZpcpVrzrz',
      'key': 'rzp_live_bXcp9inxQER7yv',
      'name': 'InstaDent',
      'order_id': orderId,
      'description': '',
      'timeout': 600, // in seconds
      'prefill': {'contact': phoneNumber.toString(), 'email': email.toString()}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      //print('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    CartAPI()
        .paymentUpdate(
            response.orderId.toString(), response.paymentId.toString())
        .then((value) {
      setState(() {
        placingOrder = false;
      });
      Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderPlacedScreen(
                      orderId: value['Response']['idc_order_id'].toString())))
          .then((value) {
        Provider.of<UpdateCartData>(context, listen: false).changeSearchView(0);
      });
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => CancelledPaymentScreen()))
        .then((value) {
      Provider.of<UpdateCartData>(context, listen: false)
          .incrementCounter()
          .then((value) {
        Provider.of<UpdateCartData>(context, listen: false)
            .showCartorNot()
            .then((value) {
          // Provider.of<UpdateCartData>(context, listen: false)
          //     .changeSearchView(0);
        });
      });
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External SDK Response: $response');
    /* Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName!,
        toastLength: Toast.LENGTH_SHORT); */
  }

  double scale = 15;
  List payOnline = [
    {"image": "upi.png", "title": "UPI"},
    {"image": "netbanking.png", "title": "Net Banking"},
    {"image": "google-pay.png", "title": "Google Pay"},
    {"image": "paytm.png", "title": "Paytm"},
    {"image": "credit-card.png", "title": "Cards"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: Text(
          "Bill total: " + widget.totalPayment.toString(),
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: placingOrder
          ? loadingProducts("Please don't press back. Placing Order...")
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      if (outofstock) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Items are Out of Stock"),
                                  content: Text(
                                    "Some items in your cart are out of stock. Please go back and remove the item from the cart to continue.",
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Go back"))
                                  ],
                                ));
                      } else {
                        setState(() {
                          placingOrder = true;
                        });
                        CartAPI().placeOrder().then((value) {
                          print(value);
                          if (value['ErrorCode'] == 0) {
                            openCheckout(value['Response']['razorpay_order']
                                    ['id']
                                .toString());
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Order place failed. Try again."),
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pay Online",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                            ),
                            Icon(Icons.arrow_right)
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: payOnline
                                .map(
                                  (e) => Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 0.7, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.asset(
                                            "assets/" + e['image'].toString(),
                                            scale: scale,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        e['title'].toString(),
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                )
                                .toList()),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 10,
                  // height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      if (outofstock) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text("Items are Out of Stock"),
                                  content: Text(
                                    "Some items in your cart are out of stock. Please go back and remove the item from the cart to continue.",
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Go back"))
                                  ],
                                ));
                      } else {
                        setState(() {
                          placingOrder = true;
                        });
                        CartAPI().cashOnDelivery().then((value) {
                          if (value['ErrorCode'] == 0) {
                            setState(() {
                              placingOrder = false;
                            });

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderPlacedScreen(
                                        orderId: value['Response']['order_id']
                                            .toString())));
                            Provider.of<UpdateCartData>(context, listen: false)
                                .changeSearchView(0);
                          }
                        });
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Pay On Delivery",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                            ),
                            Icon(Icons.arrow_right)
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.7, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/cash-payment.png",
                                  scale: scale,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "COD",
                              style: TextStyle(fontSize: 10),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 10,
                  // height: 40,
                ),
              ],
            ),
    );
  }
}
