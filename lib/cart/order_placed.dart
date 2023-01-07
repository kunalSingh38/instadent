// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:provider/provider.dart';

class OrderPlacedScreen extends StatefulWidget {
  String orderId;
  OrderPlacedScreen({required this.orderId});

  @override
  _OrderPlacedScreenState createState() => _OrderPlacedScreenState();
}

class _OrderPlacedScreenState extends State<OrderPlacedScreen> {
  List items = [];
  bool showMore = false;
  String deliverCharge = "";
  String paymentMode = "";
  String totalAmount = "";
  String total = "";
  String orderAt = "";
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CartAPI().orderDetails(widget.orderId.toString()).then((value) {
      setState(() {
        items.clear();
        items.addAll(value["items"]);
        deliverCharge = double.parse(value["delivery_charge"].toString())
            .toStringAsFixed(0);
        totalAmount =
            double.parse(value["total_price"].toString()).toStringAsFixed(0);
        total = double.parse(value["total"].toString()).toStringAsFixed(0);
        paymentMode = value["payment_mode"].toString();
        orderAt = value["order_created_at"].toString();
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
            (route) => false);
        // Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   leading: InkWell(
        //       onTap: () {
        //         Navigator.pushAndRemoveUntil(
        //             context,
        //             MaterialPageRoute(builder: (context) => Dashboard()),
        //             (route) => false);
        //       },
        //       child: SizedBox(
        //         width: 80,
        //         child: Icon(
        //           Icons.arrow_back_outlined,
        //           color: Colors.black,
        //           size: 27,
        //         ),
        //       )),
        //   elevation: 3,
        //   title: const Text(
        //     "Order Placed",
        //     textAlign: TextAlign.left,
        //     style: TextStyle(
        //         fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        //   ),
        // ),
        body: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return Center(
            child: isLoading
                ? loadingProducts("Please Wait...")
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            "assets/order_placed.gif",
                            scale: 1,
                          ),
                          Text("Your Order has been Placed.",
                              style: GoogleFonts.martelSans(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text("Delivery " + viewModel.counterDeliveryTime,
                              style: GoogleFonts.martelSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800])),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Order Details:",
                                style: GoogleFonts.martelSans(
                                    fontSize: 17, fontWeight: FontWeight.w600),
                              )),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                showMore = !showMore;
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "ID: " + widget.orderId.toUpperCase(),
                                    style: GoogleFonts.martelSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    children: items
                                        .map((e) => Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(e['product_name'],
                                                          maxLines:
                                                              showMore ? 5 : 1,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors
                                                                  .black)),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                          "QTY. " +
                                                              e['quantity']
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .blue[800])),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                          "₹ " +
                                                              (double.parse(e['offer_price']
                                                                          .toString()) /
                                                                      double.parse(e[
                                                                              'quantity']
                                                                          .toString()))
                                                                  .toStringAsFixed(
                                                                      0)
                                                                  .toString() +
                                                              " EACH",
                                                          style: TextStyle(
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.grey)),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                      "₹ " +
                                                          double.parse(
                                                                  e['offer_price']
                                                                      .toString())
                                                              .toStringAsFixed(
                                                                  0),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ))
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Delivery Charges",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                      Text("₹ " + deliverCharge,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  DottedLine(dashColor: Colors.grey),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Total Amount:",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.blue[800])),
                                      Text("₹ " + total,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        showMore
                                            ? "LESS DETAILS"
                                            : "MORE DETAILS",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.blue[800]),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      showMore
                                          ? Image.asset(
                                              "assets/up.png",
                                              scale: 30,
                                              color: Colors.blue[800],
                                            )
                                          : Image.asset(
                                              "assets/down.png",
                                              scale: 30,
                                              color: Colors.blue[800],
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            paymentMode,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            "₹ " + total,
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            orderAt,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.blue[800])),
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Dashboard()),
                                        (route) => false);
                                  },
                                  child: Text(
                                    "BACK TO HOME",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Colors.white),
                                  ))),
                        ],
                      ),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}
