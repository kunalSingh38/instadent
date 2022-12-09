// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instadent/cart/return_item_page.dart';
import 'package:instadent/constants.dart';

class ReturnOrderDetailsScreen extends StatefulWidget {
  Map m = {};
  ReturnOrderDetailsScreen({required this.m});

  @override
  _ReturnOrderDetailsScreenState createState() =>
      _ReturnOrderDetailsScreenState();
}

class _ReturnOrderDetailsScreenState extends State<ReturnOrderDetailsScreen> {
  List items = [];
  List returnItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      items.clear();
      items.addAll(widget.m['items']);
      items.forEach((element) {
        setState(() {
          element['showReturnButton'] = true;
        });
      });

      returnItems.clear();
      returnItems.addAll(widget.m['returnItem']);
    });

    if (returnItems.isNotEmpty) {
      for (var i = 0; i < returnItems.length; i++) {
        for (var j = 0; j < items.length; j++) {
          if (returnItems[i]['id'].toString() == items[j]['id'].toString()) {
            setState(() {
              items[j]['showReturnButton'] = false;
            });
          }
        }
      }
    }
    print(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: const Text(
          "Order Details",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Id",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                      Text(
                        widget.m['order_number'].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Date",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                      Text(
                        widget.m['order_date'].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order Status",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                      Text(
                        widget.m['order_status'].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Paid Amount",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                      Text(
                        "₹ " + widget.m['total'].toString(),
                        style: TextStyle(fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 0.9,
              // color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Items Details",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  items.length == 0
                      ? Text("No items to show")
                      : Column(
                          children: items
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.5)),
                                                child: cacheImage(
                                                    e['product_image']
                                                        .toString())),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SelectableText(e['product_name']
                                                    .toString()),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Qty - " +
                                                          e['quantity']
                                                              .toString() +
                                                          "  ₹" +
                                                          e['offer_price']
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    int.parse(e['quantity']
                                                                .toString()) ==
                                                            0
                                                        ? SizedBox()
                                                        : e['showReturnButton']
                                                            ? InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ReturnItemScreen(
                                                                                m: widget.m,
                                                                                index: items.indexOf(e),
                                                                              )));
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .teal,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Text(
                                                                      "Return",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : SizedBox(),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
            Divider(
              thickness: 0.9,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Returned Items Details",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  returnItems.length == 0
                      ? Text("No items to show")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: returnItems
                              .map((e) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.5)),
                                                child: cacheImage(
                                                    e['product_image']
                                                        .toString())),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SelectableText(e['product_name']
                                                    .toString()),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Qty - " +
                                                          e['return_qty']
                                                              .toString() +
                                                          "  ₹" +
                                                          e['discount_price']
                                                              .toString(),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
