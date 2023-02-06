import 'package:biz_sales_admin/apis/customer_api.dart';
import 'package:biz_sales_admin/customer/customer_details.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({Key? key}) : super(key: key);

  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  bool isLoading = true;
  List customerList = [];
  List customerListCopy = [];
  int len = 0;
  ScrollController scrollController = ScrollController();

  int count = 1;
  int last_page = 0;
  bool isLoadingCarosoleLoadMore = false;
  double totalAmount = 0;
  void totalAmt() async {
    // setState(() {
    //   totalAmount = 0;
    //   for (var element in customerList) {
    //     totalAmount = totalAmount + double.parse(element['total'].toString());
    //   }
    // });
  }

  void getOrderListData() async {
    CustomerAPI().customerListApi(count).then((value) {
      setState(() {
        searchCont.clear();
        customerList.addAll(value['data']);
        customerListCopy.addAll(value['data']);
        last_page = int.parse(value['last_page'].toString());
        isLoading = false;
        isLoadingCarosoleLoadMore = false;
        count++;
      });
      // totalAmt();
    });
  }

  void reloadApi() async {
    setState(() {
      count = 1;
      last_page = 1;
      customerList.clear();
      customerListCopy.clear();
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
                customerListCopy.forEach((item) {
                  if (item
                      .toString()
                      .toUpperCase()
                      .contains(value.toUpperCase())) {
                    dummyListData.add(item);
                  }
                });
                setState(() {
                  customerList.clear();
                  customerList.addAll(dummyListData.toSet().toList());
                });
                return;
              } else {
                setState(() {
                  customerList.clear();
                  customerList.addAll(customerListCopy);
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
                          children: customerList
                              .map(
                                (e) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CustomerDetails(m: e)));
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
                                                            child: cacheImage(
                                                                e['profile_image']
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
                                                                e['username']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        17),
                                                              ),
                                                              SizedBox(
                                                                height: 3,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "GSTN :",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      e['gstin']
                                                                          .toString()
                                                                          .toUpperCase(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
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
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Clinic Name :",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      e['clinic_name']
                                                                          .toString()
                                                                          .toUpperCase(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
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
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Mobile No :",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      e['mobile']
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
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
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Type :",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      e['customer_type']
                                                                          .toString()
                                                                          .toUpperCase(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
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
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Email Id :",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      e['email']
                                                                          .toString()
                                                                          .toUpperCase(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .w400,
                                                                          color:
                                                                              Colors.grey[600]),
                                                                    ),
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
