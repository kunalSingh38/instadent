// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/cart/cancelled_payment.dart';
import 'package:instadent/cart/payment_methods.dart';
import 'package:instadent/category/all_categories.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartView extends StatefulWidget {
  const CartView({Key? key}) : super(key: key);

  @override
  _CartViewState createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  bool itemAdded = false;
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  bool showAddress = false;
  List cartData = [];
  bool isLoading = true;
  TextEditingController controller = TextEditingController();

  String deliveryCarges = "";
  String totalPrice = "";
  String totalItemPrice = "";
  int productCount = 0;
  double originalRateTotal = 0;
  bool isLoading2 = false;
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return int.tryParse(s) != null;
  }

  List taxes = [];
  getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      CartAPI().cartData().then((value) {
        print(jsonEncode(value));
        setState(() {
          isLoading = false;
        });
        if (value.isNotEmpty) {
          if (value['items'].length > 0) {
            setState(() {
              cartData.clear();
              cartData.addAll(value['items']);
              // productCount = cartData.length;
              deliveryCarges = value['delivery_fee'].toString();
              totalPrice = value['sub_total'].toString();
              totalItemPrice = value['total'].toString();
            });

            double temp = 0;
            cartData.forEach((element) {
              temp = temp + double.parse(element['rate'].toString());
            });

            setState(() {
              originalRateTotal = temp - double.parse(totalPrice.toString());
            });

            setState(() {
              productCount = 0;
              for (var element in cartData) {
                productCount =
                    productCount + int.parse(element['quantity'].toString());
              }
            });
            Map temp2 = value['total_tax'];
            List taxSlab = [];
            temp2.forEach((key, value) {
              if (isNumeric(key.toString())) {
                taxSlab.add(key.toString());
              }
            });

            setState(() {
              taxes.clear();
              taxSlab.forEach((element) {
                taxes.add(temp2[element]);
              });
            });
            print(taxes);
          }
        } else {
          Navigator.of(context).pop();
        }
      });
      setState(() {
        showAddress = true;
      });
    } else {
      setState(() {
        showAddress = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: isLoading2
            ? PreferredSize(
                preferredSize: Size(double.infinity, 1.0),
                child: LinearProgressIndicator(),
              )
            : null,
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: const Text(
          "Checkout",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
        actions: [
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Remove all items?".toString()),
                    action: SnackBarAction(
                        label: "Remove",
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Removing items...".toString()),
                                duration: Duration(seconds: 1)),
                          );

                          CartAPI().emptyCart().then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("All items removed from cart"
                                        .toString()),
                                    duration: Duration(seconds: 1)),
                              );
                              Provider.of<UpdateCartData>(context,
                                      listen: false)
                                  .incrementCounter();
                              Provider.of<UpdateCartData>(context,
                                      listen: false)
                                  .showCartorNot();
                              Navigator.of(context).pop();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Cart removal failed".toString()),
                                    duration: Duration(seconds: 1)),
                              );
                            }
                          });
                        })),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                "assets/empty_cart.png",
                scale: 20,
              ),
            ),
          )
        ],
      ),
      bottomSheet: isLoading
          ? null
          : Consumer<UpdateCartData>(builder: (context, viewModel, child) {
              return Container(
                  height: 118,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        minLeadingWidth: 2,
                        dense: true,
                        leading: Image.asset(
                          "assets/location.png",
                          scale: 2,
                          color: Colors.teal,
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: '',
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                      text: 'Delivering to ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14)),
                                  TextSpan(
                                      text: viewModel.counterDefaultOffice
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                            Text(
                              viewModel.counterDefaultAddress.toString(),
                              maxLines: 1,
                            )
                          ],
                        ),
                        trailing: TextButton(
                            onPressed: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddressListScreen(
                                            m: {},
                                          ))).then((value) {
                                getData();
                              });
                            },
                            child: Text(
                              "Change",
                              style: TextStyle(color: Colors.green[900]),
                            )),
                      ),
                      Divider(thickness: 0.9, color: Colors.grey[400]),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.15,
                          height: 45,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.teal[800])),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentMenthosScreen(
                                                totalPayment:
                                                    double.parse(totalItemPrice)
                                                        .toStringAsFixed(2))));
                              },
                              child: Text(
                                "Select Payment Options",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white),
                              )))
                    ],
                  ));
            }),
      body: isLoading
          ? loadingProducts("Preparing your cart")
          : Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Consumer<UpdateCartData>(
                  builder: (context, viewModel, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                        child: Column(
                          children: [
                            originalRateTotal == 0
                                ? SizedBox()
                                : Column(
                                    children: [
                                      Container(
                                        // height: 35,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                                color: Colors.indigo,
                                                width: 1.5)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Your total savings",
                                                style: TextStyle(
                                                    color: Colors.indigo,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              ),
                                              Text(
                                                "₹ " +
                                                    originalRateTotal
                                                        .toStringAsFixed(0)
                                                        .replaceAll("-", ""),
                                                style: TextStyle(
                                                    color: Colors.indigo,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        child: Image.asset(
                                          "assets/clock.png",
                                          scale: 25,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[200],
                                        ))),
                                Expanded(
                                  flex: 7,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Delivery in 11 mintues",
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              productCount.toString() +
                                                  " items",
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            Text(
                                              "(incl. all taxes)",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                                children: cartData.map((e) {
                              return Column(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (isLoading2 == false) {
                                        setState(() {
                                          isLoading2 = true;
                                        });
                                        OtherAPI()
                                            .singleProductDetails(
                                                e['id'].toString())
                                            .then((value) async {
                                          setState(() {
                                            isLoading2 = false;
                                          });
                                          await showProdcutDetails(
                                              context,
                                              value,
                                              false,
                                              controller,
                                              [],
                                              dynamicLinks,
                                              true);
                                        });
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 2, 5, 2),
                                          child: Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.5)),
                                            child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: cacheImage(
                                                    e['image'].toString())),
                                          ),
                                        )),
                                        Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 2, 10, 0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e['product_name']
                                                        .toString(),
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13),
                                                  ),
                                                  // SizedBox(
                                                  //   height: 5,
                                                  // ),
                                                  // Text(
                                                  //   "500 g",
                                                  //   textAlign: TextAlign.left,
                                                  //   maxLines: 1,
                                                  //   style: TextStyle(
                                                  //       fontWeight:
                                                  //           FontWeight.w300,
                                                  //       fontSize: 12),
                                                  // ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          "₹" +
                                                              e['offer_price']
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15)),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          "₹" +
                                                              e['rate']
                                                                  .toString(),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13,
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              color:
                                                                  Colors.grey))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )),
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15, right: 10),
                                          child: Container(
                                            width: 75,
                                            height: 28,
                                            decoration: BoxDecoration(
                                                color: e['quantity'] > 0
                                                    ? Colors.teal[400]
                                                    : Colors.teal[50],
                                                border: Border.all(
                                                    color: Color(0xFF004D40)),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: e['quantity'] > 0
                                                ? Stack(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    8, 4, 2, 4),
                                                            child: Text(
                                                              "-",
                                                              style: textStyle1,
                                                            ),
                                                          ),
                                                          Text(
                                                            e['quantity']
                                                                .toString(),
                                                            style: textStyle1,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    2, 4, 8, 4),
                                                            child: Text(
                                                              "+",
                                                              style: textStyle1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              await setQunatity(
                                                                  cartData
                                                                      .indexOf(
                                                                          e),
                                                                  false);
                                                            },
                                                            child: Container(
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                          )),
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                controller
                                                                    .clear();
                                                              });
                                                              await manuallyUpdateQuantity(
                                                                  cartData
                                                                      .indexOf(
                                                                          e));
                                                            },
                                                            child: Container(
                                                                color: Colors
                                                                    .transparent),
                                                          )),
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              await setQunatity(
                                                                  cartData
                                                                      .indexOf(
                                                                          e),
                                                                  true);
                                                            },
                                                            child: Container(
                                                                color: Colors
                                                                    .transparent),
                                                          ))
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      await setQunatity(
                                                          cartData.indexOf(e),
                                                          true);
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  8, 2, 8, 2),
                                                          child: Center(
                                                            child: Text(
                                                              "ADD",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                          .teal[
                                                                      900]),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors
                                                                .teal[900],
                                                            size: 10,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              );
                            }).toList()),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[350],
                        thickness: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sub Total (incl. taxes)",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '',
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      // TextSpan(
                                      //     text: "₹" + "266",
                                      //     style: TextStyle(
                                      //         decoration:
                                      //             TextDecoration.lineThrough,
                                      //         fontWeight: FontWeight.w400,
                                      //         color: Colors.grey,
                                      //         fontSize: 14)),
                                      TextSpan(
                                          text: " ₹" +
                                              double.parse(
                                                      totalPrice.toString())
                                                  .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children: taxes
                                  .map((e) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            e['title'].toString() +
                                                " (" +
                                                e['rate'].toString() +
                                                "%)",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            "₹" +
                                                double.parse(e['tax_amount']
                                                        .toString())
                                                    .toStringAsFixed(2),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          )
                                        ],
                                      ))
                                  .toList(),
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Delivery charge",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    PopupMenuButton(
                                      position: PopupMenuPosition.under,
                                      padding: EdgeInsets.zero,
                                      icon: Image.asset(
                                        "assets/information.png",
                                        scale: 35,
                                        color: Colors.green,
                                      ),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                            child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Testing information"),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ],
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: '',
                                    style: DefaultTextStyle.of(context).style,
                                    children: [
                                      TextSpan(
                                          text: "",
                                          style: TextStyle(
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey,
                                              fontSize: 14)),
                                      TextSpan(
                                          text: " ₹" +
                                              double.parse(
                                                      deliveryCarges.toString())
                                                  .toStringAsFixed(2),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 10,
                            // ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Bill total",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "₹" +
                                        double.parse(totalItemPrice)
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ])
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey[350],
                        thickness: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Cancellation Policy",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w800, fontSize: 16)),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                                "Orders cannot be cancelled once packed for delivery. In case of unexpected delays, a refund will be provided, if applicable.",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Future setQunatity(int index, bool action) async {
    setState(() {
      isLoading = true;
    });
    if (action) {
      cartData[index]['quantity'] = cartData[index]['quantity'] + 1;
      setState(() {
        Map m = {
          "offer_price": cartData[index]['offer_price'].toString(),
          "rate": int.parse(cartData[index]['rate'].toString().split(".")[0]),
          "quantity": cartData[index]['quantity'].toString(),
          "product_id": cartData[index]['product_id'].toString()
        };

        CartAPI().addToCart(m).then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .incrementCounter()
              .then((value) {
            Provider.of<UpdateCartData>(context, listen: false)
                .showCartorNot()
                .then((value) {
              setState(() {
                isLoading = false;
              });
              getData();
            });
          });
        });
      });
    } else {
      cartData[index]['quantity'] = cartData[index]['quantity'] - 1;
      setState(() {
        Map m = {
          "offer_price": cartData[index]['offer_price'].toString(),
          "rate": int.parse(cartData[index]['rate'].toString().split(".")[0]),
          "quantity": cartData[index]['quantity'].toString(),
          "product_id": cartData[index]['product_id'].toString()
        };
        CartAPI().addToCart(m).then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .incrementCounter()
              .then((value) {
            Provider.of<UpdateCartData>(context, listen: false)
                .showCartorNot()
                .then((value) {
              setState(() {
                isLoading = false;
              });
              getData();
            });
          });
        });
      });
    }
    // setState(() {
    //   productCount = 0;
    //   cartData.forEach((element) {
    //     productCount = productCount + int.parse(element['quantity'].toString());
    //   });
    // });
  }

  Future<void> manuallyUpdateQuantity(int index) async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            height: 180,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Color(0xFFEEEEEE))),
                        child: TextFormField(
                          autofocus: true,
                          controller: controller,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter qunatity",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.15,
                          height: 45,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.green[700])),
                              onPressed: () async {
                                setState(() {
                                  cartData[index]['quantity'] =
                                      int.parse(controller.text);

                                  Map m = {
                                    "offer_price": cartData[index]
                                            ['offer_price']
                                        .toString(),
                                    "rate": int.parse(cartData[index]['rate']
                                        .toString()
                                        .split(".")[0]),
                                    "quantity":
                                        cartData[index]['quantity'].toString(),
                                    "product_id":
                                        cartData[index]['product_id'].toString()
                                  };
                                  print(m);
                                  //
                                  CartAPI().addToCart(m).then((value) {
                                    Provider.of<UpdateCartData>(context,
                                            listen: false)
                                        .incrementCounter()
                                        .then((value) {
                                      Provider.of<UpdateCartData>(context,
                                              listen: false)
                                          .showCartorNot()
                                          .then((value) {
                                            getData();
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Cart Updated".toString()),
                                              duration: Duration(seconds: 1)),
                                        );
                                      });
                                    });
                                  });
                                });
                              },
                              child: Text(
                                "Update",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                              ))),
                    ])))));
  }
}
