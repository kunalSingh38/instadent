// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/cart/order_summary.dart';
import 'package:instadent/constants.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool isLoading = true;
  List openOrder = [];
  List completedOrder = [];
  int len = 0;
  List returnItems = [];
  List replacementItems = [];

  void getOrderDetails(String url) async {
    CartAPI().orderHistory(url).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value['ErrorCode'] == 0) {
        switch (url) {
          case "orders/open":
            setState(() {
              openOrder.clear();
              openOrder.addAll(value['Response']);
              len = openOrder.length;
            });
            break;
          case "orders/completed":
            setState(() {
              completedOrder.clear();
              completedOrder.addAll(value['Response']);
              len = completedOrder.length;
            });
            break;
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrderDetails("orders/open");
  }

  @override
  Widget build(BuildContext context) {
    // print(DateFormat("EEE, d MMMM yyyy, hh:mm a")
    //     .format(DateTime.parse("03-Mar-2022 04:03:13 PM")));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: Text(
          "Order History (" + len.toString() + ")",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: ContainedTabBarView(
            tabBarProperties: TabBarProperties(
                height: 40,
                indicatorColor: Colors.teal,
                indicatorWeight: 5,
                background: Container(
                  color: Colors.grey[300],
                )),
            tabs: [
              Text(
                'Open',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Text(
                'Completed',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Text(
                'Return',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
              Text(
                'Replacement',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              ),
            ],
            initialIndex: 0,
            onChange: (index) {
              switch (index) {
                case 0:
                  getOrderDetails("orders/open");
                  break;

                case 1:
                  getOrderDetails("orders/completed");
                  break;
                case 2:
                  OtherAPI().returnReplacementRequestList("1").then((value) {
                    setState(() {
                      returnItems.clear();
                      returnItems.addAll(value);
                    });
                  });
                  break;
                case 3:
                  OtherAPI().returnReplacementRequestList("2").then((value) {
                    setState(() {
                      replacementItems.clear();
                      replacementItems.addAll(value);
                    });
                  });
                  break;
              }
            },
            views: [
              openOrder.length == 0
                  ? Center(
                      child: Text("No data available"),
                    )
                  : ListView(
                      children: openOrder
                          .map((e) => InkWell(
                                onTap: () {
                                  print(e['current_status'].toString());
                                  // if (e['current_status'].toString() !=
                                  //     "Returned") {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OrderSummaryScreen(
                                                map: e,
                                              ))).then((value) {
                                    getOrderDetails("orders/open");
                                  });
                                  // }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFFE0E0E0)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                                color: Colors.grey[200],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFE0E0E0),
                                                      radius: 25,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 24.5,
                                                          child: Image.asset(
                                                            "assets/orderImage.png",
                                                            scale: 15,
                                                          )),
                                                    ),
                                                  )),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e['orderId']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 17),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              "Total Amount : ₹" +
                                                                  e['amount']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      e['current_status']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Payment Method",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[600]),
                                              ),
                                              Text(
                                                e['payment_mode']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.8,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 1, 8, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "Placed on " +
                                                      e['order_date']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[700])),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "View details",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.green[900],
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_right,
                                                    size: 18,
                                                    color: Colors.green[900],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
              completedOrder.length == 0
                  ? Center(
                      child: Text("No data available"),
                    )
                  : ListView(
                      children: completedOrder
                          .map((e) => InkWell(
                                onTap: () {
                                  if (e['current_status'].toString() !=
                                      "Returned") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                OrderSummaryScreen(
                                                  map: e,
                                                ))).then((value) {
                                      getOrderDetails("orders/completed");
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFFE0E0E0)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 70,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                                color: Colors.grey[200],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFE0E0E0),
                                                      radius: 25,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 24.5,
                                                          child: Image.asset(
                                                            "assets/orderImage.png",
                                                            scale: 15,
                                                          )),
                                                    ),
                                                  )),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e['orderId']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 17),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              "Total Amount : ₹" +
                                                                  e['amount']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            )
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      e['current_status']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "13 items",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[600]),
                                              ),
                                              Text(
                                                e['payment_mode']
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.8,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 1, 8, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "Placed on " +
                                                      e['order_date']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[700])),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    "View details",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.green[900],
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_right,
                                                    size: 18,
                                                    color: Colors.green[900],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
              returnItems.length == 0
                  ? Center(
                      child: Text("No data available"),
                    )
                  : ListView(
                      children: returnItems
                          .map((e) => InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFFE0E0E0)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 90,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                                color: Colors.grey[200],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFE0E0E0),
                                                      radius: 25,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 24.5,
                                                          child: Image.asset(
                                                            "assets/return.png",
                                                            scale: 15,
                                                          )),
                                                    ),
                                                  )),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e['request_no']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 17),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              "Total Amount : ₹" +
                                                                  e['total']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                e["item_name"]
                                                                    .toString(),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                            .grey[
                                                                        600]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      "Returned",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Reason : ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[600]),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  e['reason'].toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[600]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.8,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 1, 8, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "Return on " +
                                                      e['created_at']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[700])),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.end,
                                              //   children: [
                                              //     Text(
                                              //       "View details",
                                              //       style: TextStyle(
                                              //           color: Colors.green[900],
                                              //           fontSize: 12,
                                              //           fontWeight: FontWeight.w700),
                                              //     ),
                                              //     Icon(
                                              //       Icons.arrow_right,
                                              //       size: 18,
                                              //       color: Colors.green[900],
                                              //     )
                                              //   ],
                                              // )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
              replacementItems.length == 0
                  ? Center(
                      child: Text("No data available"),
                    )
                  : ListView(
                      children: replacementItems
                          .map((e) => InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xFFE0E0E0)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            Container(
                                              height: 90,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10)),
                                                color: Colors.grey[200],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: Padding(
                                                    padding: EdgeInsets.all(5),
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Color(0xFFE0E0E0),
                                                      radius: 25,
                                                      child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          radius: 24.5,
                                                          child: Image.asset(
                                                            "assets/replacement.png",
                                                            scale: 18,
                                                          )),
                                                    ),
                                                  )),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              e['request_no']
                                                                  .toString()
                                                                  .toUpperCase(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 17),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Text(
                                                              "Total Amount : ₹" +
                                                                  e['total']
                                                                      .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                          .grey[
                                                                      600]),
                                                            ),
                                                            SizedBox(
                                                              height: 3,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                e["item_name"]
                                                                    .toString(),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                            .grey[
                                                                        600]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, right: 8),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[300],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Text(
                                                      "Replacement",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600]),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 8, 8, 1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Reason : ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.grey[600]),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  e['reason'].toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[600]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 0.8,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 1, 8, 5),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                  "Return on " +
                                                      e['created_at']
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.grey[700])),
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment.end,
                                              //   children: [
                                              //     Text(
                                              //       "View details",
                                              //       style: TextStyle(
                                              //           color: Colors.green[900],
                                              //           fontSize: 12,
                                              //           fontWeight: FontWeight.w700),
                                              //     ),
                                              //     Icon(
                                              //       Icons.arrow_right,
                                              //       size: 18,
                                              //       color: Colors.green[900],
                                              //     )
                                              //   ],
                                              // )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ]),
      ),
    );
  }
}
