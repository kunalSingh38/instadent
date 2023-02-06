import 'package:biz_sales_admin/apis/orders_api.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:biz_sales_admin/orders/order_details.dart';
import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  bool isLoading = true;
  List ordersList = [];
  List ordersListCopy = [];
  int len = 0;
  ScrollController scrollController = ScrollController();

  int count = 1;
  int last_page = 0;
  bool isLoadingCarosoleLoadMore = false;
  double totalAmount = 0;
  void totalAmt() async {
    setState(() {
      totalAmount = 0;
      for (var element in ordersList) {
        totalAmount = totalAmount + double.parse(element['total'].toString());
      }
    });
  }

  void getOrderListData() async {
    OrdersAPI().ordersListApi(count).then((value) {
      setState(() {
        searchCont.clear();
        ordersList.addAll(value['data']);
        ordersListCopy.addAll(value['data']);
        last_page = int.parse(value['last_page'].toString());
        isLoading = false;
        isLoadingCarosoleLoadMore = false;
        count++;
      });
      totalAmt();
    });
  }

  void reloadApi() async {
    setState(() {
      count = 1;
      last_page = 1;
      ordersList.clear();
      ordersListCopy.clear();
      totalAmount = 0;
    });
    scrollController.addListener(() {
      if (scrollController.offset >=
              scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        if (count <= last_page && !isLoadingCarosoleLoadMore) {
          setState(() {
            isLoadingCarosoleLoadMore = true;
          });
          getOrderListData();
        }
      }
    });
    getOrderListData();
  }

  TextEditingController searchCont = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reloadApi();
  }

  @override
  Widget build(BuildContext context) {
    // print(DateFormat("EEE, d MMMM yyyy, hh:mm a")
    //     .format(DateTime.parse("03-Mar-2022 04:03:13 PM")));

    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Row(
              children: [
                PopupMenuButton<String>(
                    icon: Image.asset(
                      "assets/filter.png",
                      scale: 25,
                      color: Colors.blue[900],
                    ),
                    onSelected: (value) {
                      if (value == "All") {
                        reloadApi();
                      } else {
                        setState(() {
                          searchCont.clear();
                          searchCont.text = value;
                        });
                        FocusScope.of(context).unfocus();
                        if (value.isNotEmpty) {
                          List dummyListData = [];
                          ordersListCopy.forEach((item) {
                            if (item
                                .toString()
                                .toUpperCase()
                                .contains(value.toUpperCase())) {
                              dummyListData.add(item);
                            }
                          });
                          setState(() {
                            ordersList.clear();
                            ordersList.addAll(dummyListData.toSet().toList());
                          });
                          return;
                        } else {
                          setState(() {
                            ordersList.clear();
                            ordersList.addAll(ordersListCopy);
                          });
                          reloadApi();
                        }
                      }
                    },
                    itemBuilder: (context) => [
                          "All",
                          "New",
                          "Accepted",
                          "Rejected",
                          "Delivered",
                          "Shipped",
                        ]
                            .map((e) => PopupMenuItem<String>(
                                  value: e,
                                  child: Text(e.toString()),
                                ))
                            .toList()),
                InkWell(
                  onTap: () {
                    searchDateWise();
                  },
                  child: Image.asset(
                    "assets/calendar.png",
                    scale: 25,
                    color: Colors.blue[900],
                  ),
                )
              ],
            ),
            leadingWidth: 70,
            title: TextFormField(
              controller: searchCont,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              onChanged: (value) async {
                if (value.isNotEmpty) {
                  List dummyListData = [];
                  ordersListCopy.forEach((item) {
                    if (item
                        .toString()
                        .toUpperCase()
                        .contains(value.toUpperCase())) {
                      dummyListData.add(item);
                    }
                  });
                  setState(() {
                    ordersList.clear();
                    ordersList.addAll(dummyListData.toSet().toList());
                  });
                  return;
                } else {
                  setState(() {
                    ordersList.clear();
                    ordersList.addAll(ordersListCopy);
                  });
                  reloadApi();
                }
              },
              decoration: InputDecoration(
                  // isCollapsed: true,
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding: EdgeInsets.all(5),
                  // focusedBorder: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.lightBlue),
                  //     borderRadius: BorderRadius.circular(10)),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: "Search",
                  hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w300),

                  //  InkWell(
                  //     onTap: () {},
                  //     child: Image.asset(
                  //       "assets/filter.png",
                  //       scale: 25,
                  //       color: Colors.blue[900],
                  //     )),
                  suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          searchCont.clear();
                        });
                        reloadApi();
                        FocusScope.of(context).unfocus();
                      },
                      child: Image.asset(
                        "assets/clear.png",
                        scale: 35,
                      ))),
            ),
          ),
          backgroundColor: Colors.blue[50],
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                isLoading = true;
                isLoadingCarosoleLoadMore = false;
              });
              reloadApi();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // height: 200,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.teal[300]),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Orders : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                              Text(
                                ordersList.length.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Amount : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.white),
                              ),
                              Text(
                                "₹ " + totalAmount.toStringAsFixed(2),
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 25,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //         child: Column(
                          //       children: [Text("COD"), Text("200")],
                          //     )),
                          //     Expanded(
                          //         child: Column(
                          //       children: [Text("Online"), Text("200")],
                          //     ))
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[100]),
                      child: ListView(
                        controller: scrollController,
                        physics: BouncingScrollPhysics(),
                        children: ordersList
                            .map((e) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OrderDetails(
                                                  m: e,
                                                ))).then((value) {
                                      reloadApi();
                                    });
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
                                                // height: 95,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          topRight:
                                                              Radius.circular(
                                                                  10)),
                                                  color: Colors.grey[200],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        child: Padding(
                                                      padding:
                                                          EdgeInsets.all(5),
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
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    e['order_id']
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[
                                                                            300],
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              5.0),
                                                                      child:
                                                                          Text(
                                                                        e['orderstatus']
                                                                            .toString(),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey[600]),
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Total Amount :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Text(
                                                                    "₹" +
                                                                        double.parse(e['total'].toString())
                                                                            .toStringAsFixed(2),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Payment Mode :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  e['payment_mode'] ==
                                                                          null
                                                                      ? Text(
                                                                          "-",
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Colors.black),
                                                                        )
                                                                      : Text(
                                                                          e['payment_mode']
                                                                              .toString()
                                                                              .toUpperCase(),
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: Colors.black),
                                                                        ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Cust Name :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Text(
                                                                    e['customer_name']
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Cust Mobile :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Text(
                                                                    e['mobile_no']
                                                                        .toString()
                                                                        .toUpperCase(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "Placed on " +
                                                        e['created_at']
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color:
                                                            Colors.grey[700])),
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
                    )),
              ],
            ),
          )),
    );
  }

  Future<void> searchDateWise() async {
    TextEditingController firstDate = TextEditingController();
    TextEditingController lastDate = TextEditingController();
    setState(() {
      firstDate.clear();
      lastDate.clear();
    });
    GlobalKey<FormState> dateFilter = GlobalKey();
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isDismissible: false,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: SingleChildScrollView(
                    child: Form(
                  key: dateFilter,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Date Wise Search",
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                            IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ))
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: firstDate,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(12),
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      filled: true,
                                      isCollapsed: true,
                                      isDense: true,
                                      hintText: "From date"),
                                  readOnly: true,
                                  validator: (value) {
                                    if (value.toString().isEmpty) {
                                      return "Please select date";
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2001),
                                            lastDate: DateTime(2101));
                                    if (picked != null) {
                                      setState(() {
                                        firstDate.text =
                                            picked.toString().split(" ")[0];
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: lastDate,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(12),
                                      border: OutlineInputBorder(),
                                      fillColor: Colors.white,
                                      filled: true,
                                      isCollapsed: true,
                                      isDense: true,
                                      hintText: "To date"),
                                  readOnly: true,
                                  validator: (value) {
                                    if (value.toString().isEmpty) {
                                      return "Please select date";
                                    }
                                    return null;
                                  },
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2001),
                                            lastDate: DateTime(2101));
                                    if (picked != null) {
                                      setState(() {
                                        lastDate.text =
                                            picked.toString().split(" ")[0];
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
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
                                        Colors.teal[700])),
                                onPressed: () {
                                  if (dateFilter.currentState!.validate()) {
                                    if (DateTime.parse(firstDate.text).isAfter(
                                        DateTime.parse(lastDate.text))) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              duration: Duration(seconds: 1),
                                              content: Text(
                                                  "From date can't be less than To date."
                                                      .toString())));
                                    } else {
                                      showLaoding(context);
                                      setState(() {
                                        ordersList.clear();
                                        ordersList.addAll(ordersListCopy.where(
                                            (element) =>
                                                DateTime.parse(element['created_at'])
                                                    .isAfter(DateTime.parse(
                                                        firstDate.text)) &&
                                                DateTime.parse(
                                                        element['created_at'])
                                                    .isBefore(DateTime.parse(
                                                            lastDate.text)
                                                        .add(
                                                            Duration(days: 1)))));
                                        totalAmt();
                                      });
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                      Navigator.of(context,
                                              rootNavigator: false)
                                          .pop();
                                    }
                                  }
                                },
                                child: Text(
                                  "Search",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.white),
                                ))),
                      ]),
                )),
              );
            }));
  }
}
