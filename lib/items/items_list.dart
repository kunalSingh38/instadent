import 'package:biz_sales_admin/apis/items_api.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:biz_sales_admin/items/item_details.dart';
import 'package:flutter/material.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
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
    // setState(() {
    //   totalAmount = 0;
    //   for (var element in ordersList) {
    //     totalAmount = totalAmount + double.parse(element['total'].toString());
    //   }
    // });
  }

  void getOrderListData() async {
    ItemsAPI().itemsListApi(count).then((value) {
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
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
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
                // prefixIcon: PopupMenuButton<String>(
                //     icon: Image.asset(
                //       "assets/filter.png",
                //       scale: 25,
                //       color: Colors.blue[900],
                //     ),
                //     onSelected: (value) {
                //       if (value == "All") {
                //         reloadApi();
                //       } else if (value == "Date Wise") {
                //         searchDateWise();
                //       } else {
                //         setState(() {
                //           searchCont.clear();
                //           searchCont.text = value;
                //         });
                //         FocusScope.of(context).unfocus();
                //         if (value.isNotEmpty) {
                //           List dummyListData = [];
                //           ordersListCopy.forEach((item) {
                //             if (item
                //                 .toString()
                //                 .toUpperCase()
                //                 .contains(value.toUpperCase())) {
                //               dummyListData.add(item);
                //             }
                //           });
                //           setState(() {
                //             ordersList.clear();
                //             ordersList.addAll(dummyListData.toSet().toList());
                //           });
                //           return;
                //         } else {
                //           setState(() {
                //             ordersList.clear();
                //             ordersList.addAll(ordersListCopy);
                //           });
                //           reloadApi();
                //         }
                //       }
                //     },
                //     itemBuilder: (context) => [
                //           "All",
                //           "New",
                //           "Accepted",
                //           "Rejected",
                //           "Delivered",
                //           "Shipped",
                //           "Date Wise"
                //         ]
                //             .map((e) => PopupMenuItem<String>(
                //                   value: e,
                //                   child: Text(e.toString()),
                //                 ))
                //             .toList()),

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
            child: Column(children: [
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
                              .map(
                                (e) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ItemDetails(map: e)));
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
                                                            child: cacheImage(e[
                                                                    'image']
                                                                .toString())),
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
                                                                e['item_name']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Text(
                                                                e['product_code']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12),
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
                                                                    "MRP :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Text(
                                                                    "₹" +
                                                                        e['item_price']
                                                                            .toString(),
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
                                                              // Row(
                                                              //   mainAxisAlignment:
                                                              //       MainAxisAlignment
                                                              //           .spaceBetween,
                                                              //   children: [
                                                              //     Text(
                                                              //       "Selling Price :",
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w400,
                                                              //           color: Colors
                                                              //               .grey[600]),
                                                              //     ),
                                                              //     Text(
                                                              //       "₹" +
                                                              //           e['dealer_trade_price']
                                                              //               .toString()
                                                              //               .toUpperCase(),
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w600,
                                                              //           color: Colors
                                                              //               .black),
                                                              //     ),
                                                              //   ],
                                                              // ),

                                                              // SizedBox(
                                                              //   height: 3,
                                                              // ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Selling Price :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Text(
                                                                    "₹" +
                                                                        e['discount_price']
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
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    "Category :",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        color: Colors
                                                                            .grey[600]),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        e['category_hirarchy']['parent_name']
                                                                            .toString()
                                                                            .toUpperCase(),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.black),
                                                                      ),
                                                                      e['category_hirarchy']['sub_category']['name'] ==
                                                                              ""
                                                                          ? SizedBox()
                                                                          : Text(
                                                                              "->" + e['category_hirarchy']['sub_category']['name'].toString().toUpperCase(),
                                                                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              // SizedBox(
                                                              //   height: 3,
                                                              // ),

                                                              // Row(
                                                              //   mainAxisAlignment:
                                                              //       MainAxisAlignment
                                                              //           .spaceBetween,
                                                              //   children: [
                                                              //     Text(
                                                              //       "L x W x H (cm) :",
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               12,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w400,
                                                              //           color: Colors
                                                              //               .grey[600]),
                                                              //     ),
                                                              //     Text(
                                                              //       e['item_length'].toString() +
                                                              //           " x " +
                                                              //           e['item_width']
                                                              //               .toString() +
                                                              //           " x " +
                                                              //           e['item_height']
                                                              //               .toString(),
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w600,
                                                              //           color: Colors
                                                              //               .black),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                              // SizedBox(
                                                              //   height: 3,
                                                              // ),
                                                              // Row(
                                                              //   mainAxisAlignment:
                                                              //       MainAxisAlignment
                                                              //           .spaceBetween,
                                                              //   children: [
                                                              //     Text(
                                                              //       "Weight (gm) :",
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w400,
                                                              //           color: Colors
                                                              //               .grey[600]),
                                                              //     ),
                                                              //     Text(
                                                              //       e['item_weight']
                                                              //           .toString()
                                                              //           .toUpperCase(),
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w600,
                                                              //           color: Colors
                                                              //               .black),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                              // SizedBox(
                                                              //   height: 3,
                                                              // ),
                                                              // Row(
                                                              //   mainAxisAlignment:
                                                              //       MainAxisAlignment
                                                              //           .spaceBetween,
                                                              //   children: [
                                                              //     Text(
                                                              //       "Available Stock :",
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w400,
                                                              //           color: Colors
                                                              //               .grey[600]),
                                                              //     ),
                                                              //     Text(
                                                              //       e['item_weight']
                                                              //           .toString()
                                                              //           .toUpperCase(),
                                                              //       style: TextStyle(
                                                              //           fontSize:
                                                              //               14,
                                                              //           fontWeight:
                                                              //               FontWeight
                                                              //                   .w600,
                                                              //           color: Colors
                                                              //               .black),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                              // SizedBox(
                                                              //   height: 3,
                                                              // ),
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
                                ),
                              )
                              .toList())))
            ])));
  }
}
