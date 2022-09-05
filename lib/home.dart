// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/category/sub_categories.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/main.dart';
import 'package:instadent/search/search.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchCont = TextEditingController();

  TextStyle textStyle1 = TextStyle(color: Colors.white);
  GlobalKey key = GlobalKey();
  String defaultAddress = "Select Address";
  String addressType = "Other";
  // List addressList = [];
  bool isLoadingAllCategory = true;
  bool isLoadingCarosole = true;
  Future<void> getAddressList() async {
    _determinePosition().then((value) {
      _getAddress(value);
    });
  }

  Widget onlySearch() => InkWell(
        onTap: () {
          Provider.of<UpdateCartData>(context, listen: false)
              .changeSearchView(2);
        },
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 3,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 25,
                  )),
                  Expanded(
                      flex: 10,
                      child: Text(
                        searchHint,
                        style: TextStyle(fontSize: 15),
                      ))
                ],
              ),
            )),
      );
  Widget searchCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
              color: Color(0xFFEEEEEE),
            )),
        child: TextFormField(
          controller: searchCont,
          readOnly: true,
          // style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          onTap: () {
            Provider.of<UpdateCartData>(context, listen: false)
                .changeSearchView(2);
          },
          decoration: InputDecoration(
            isDense: true,
            isCollapsed: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.all(5),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10)),
            hintText: searchHint,
            hintStyle: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
            prefixIcon: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 28,
                )),
          ),
        ),
      );

  ScrollController scrollController = ScrollController();
  double scrollOffset = 0;
  List categoryList = [];
  TextEditingController controller = TextEditingController();

  List carouselsList = [];
  Future<void> getCarouselsListData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    // if (pref.getBool("loggedIn") ?? false) {
    //   OtherAPI().carouselsWithLogin().then((value) {
    //     setState(() {
    //       carouselsList.clear();
    //       carouselsList.addAll(value);
    //     });
    //   });
    // } else {
    OtherAPI().carouselsWithoutLogin().then((value) {
      setState(() {
        carouselsList.clear();
        carouselsList.addAll(value);
        isLoadingCarosole = false;
      });
    });
    // }
  }

  @override
  void dispose() {
    scrollController.dispose();
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    CategoryAPI().cartegoryList().then((value) {
      setState(() {
        categoryList.clear();
        categoryList.addAll(value);
        isLoadingAllCategory = false;
      });
    });
    getAddressList();
    getCarouselsListData();
    Provider.of<UpdateCartData>(context, listen: false).counterShowCart;
  }

  bool showSearch = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: Colors.teal[100],
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Close this app?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Image.asset(
                        "assets/logo.png",
                        scale: 2,
                      )
                    ],
                  ),
                  content: Text("Are you sure you want to exit.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        )),
                    TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.black),
                        )),
                  ],
                ));
      },
      child: SafeArea(
        child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: showSearch
                  ? AppBar(
                      backgroundColor: Colors.white,
                      toolbarHeight: 60,
                      title: onlySearch())
                  : null,
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                              child: Text("Delivery in 11 mintues",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 20)),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddressListScreen()))
                                      .then((value) async {
                                    // SharedPreferences pref =
                                    //     await SharedPreferences
                                    //         .getInstance();

                                    // setState(() {
                                    //   addressType = pref
                                    //       .getString("address_type")
                                    //       .toString();
                                    //   defaultAddress = pref
                                    //       .getString("defaultAddress")
                                    //       .toString();
                                    // });
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 15,
                                      child: Text(
                                          viewModel.counterDefaultOffice
                                                  .toString() +
                                              ", " +
                                              viewModel.counterDefaultAddress
                                                  .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15)),
                                    ),
                                    Expanded(child: Icon(Icons.arrow_drop_down))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: onlySearch(),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[50]),
                                child: ImageSlideshow(
                                  width: double.infinity,
                                  height: 160,
                                  initialPage: 0,
                                  indicatorColor: Colors.blue,
                                  indicatorBackgroundColor: Colors.grey,
                                  children: List.generate(
                                      3,
                                      (index) => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              'assets/banner' +
                                                  (index + 1).toString() +
                                                  '.jpeg',
                                              fit: BoxFit.fill,
                                            ),
                                          )).toList(),
                                  onPageChanged: (value) {},
                                  autoPlayInterval: 3000,
                                  isLoop: true,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Divider(
                              color: Colors.grey[200],
                              thickness: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "All categories",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  isLoadingAllCategory
                                      ? Container(
                                          height: 300,
                                          child: loadingProducts(
                                              "Getting your InstaDent products"),
                                        )
                                      : allCategoryGrid(categoryList, context),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          color: Colors.grey[200],
                          thickness: 15,
                        ),
                        isLoadingCarosole
                            ? loadingProducts(
                                "Getting your InstaDent sepecial products")
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: carouselsList.map((e) {
                                  List items = e['items'];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e['carousel_name'].toString(),
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              items.length.toString() +
                                                  " products",
                                              style: GoogleFonts.montserrat(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 15, 10),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                              children: items.map((e) {
                                            bool inStock = e['is_stock'] == 1
                                                ? false
                                                : true;

                                            String disccount = "";
                                            String temp = e['item_discount']
                                                .toString()
                                                .split("%")[0];

                                            if (temp.split(".")[0].toString() ==
                                                    "0" &&
                                                temp.split(".")[1].toString() ==
                                                    "00") {
                                              disccount = "0";
                                            } else if (temp
                                                    .split(".")[1]
                                                    .toString() ==
                                                "00") {
                                              disccount =
                                                  temp.split(".")[0].toString();
                                            } else {
                                              disccount = temp;
                                            }

                                            return Stack(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    await showProdcutDetails(
                                                        context,
                                                        e,
                                                        inStock,
                                                        controller,
                                                        items);
                                                  },
                                                  child: Container(
                                                    width: 170,
                                                    height: 250,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color: Color(
                                                                0xFFD6D6D6),
                                                            width: 0.3)),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 15),
                                                            child:
                                                                Image.network(
                                                              e['product_image']
                                                                  .toString(),
                                                              scale: 10,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Image
                                                                    .asset(
                                                                  "assets/no_image.jpeg",
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                        // SizedBox(
                                                        //   height: 2,
                                                        // ),
                                                        Expanded(
                                                            child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10,
                                                                  15,
                                                                  8,
                                                                  10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                e['product_name']
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        12),
                                                              ),
                                                              // Text(
                                                              //   "500 g",
                                                              //   textAlign: TextAlign.left,
                                                              //   maxLines: 1,
                                                              //   style: TextStyle(
                                                              //       fontWeight: FontWeight.w300, fontSize: 12),
                                                              // ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                          "₹" +
                                                                              e['discount_price']
                                                                                  .toString(),
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w700,
                                                                              fontSize: 12)),
                                                                      Text(
                                                                          "₹" +
                                                                              e['mrp']
                                                                                  .toString(),
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.w400,
                                                                              fontSize: 11,
                                                                              decoration: TextDecoration.lineThrough,
                                                                              color: Colors.grey))
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                disccount == "0"
                                                    ? SizedBox()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 12),
                                                        child: Container(
                                                          width: 90,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.teal,
                                                              borderRadius: BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10))),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(
                                                              " " +
                                                                  disccount
                                                                      .toString() +
                                                                  "% OFF",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  // height: 20,
                                                  // width: 30,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10,
                                                            right: 10),
                                                    child: inStock
                                                        ? Container(
                                                            width: 75,
                                                            height: 28,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[350],
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      8,
                                                                      2,
                                                                      8,
                                                                      2),
                                                              child: Center(
                                                                child: Text(
                                                                  "Out of Stock",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          9,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                              ),
                                                            ))
                                                        : Container(
                                                            width: 75,
                                                            height: 28,
                                                            decoration: BoxDecoration(
                                                                color: e['quantity'] >
                                                                        0
                                                                    ? Colors.teal[
                                                                        400]
                                                                    : Colors.teal[
                                                                        50],
                                                                border: Border.all(
                                                                    color: Color(
                                                                        0xFF004D40)),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child:
                                                                e['quantity'] >
                                                                        0
                                                                    ? Stack(
                                                                        children: [
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(8, 4, 2, 4),
                                                                                child: Text(
                                                                                  "-",
                                                                                  style: textStyle1,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                e['quantity'].toString(),
                                                                                style: textStyle1,
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.fromLTRB(2, 4, 8, 4),
                                                                                child: Text(
                                                                                  "+",
                                                                                  style: textStyle1,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Expanded(
                                                                                  child: InkWell(
                                                                                onTap: () async {
                                                                                  await setQunatity(items.indexOf(e), false, items, context);
                                                                                },
                                                                                child: Container(
                                                                                  color: Colors.transparent,
                                                                                ),
                                                                              )),
                                                                              Expanded(
                                                                                  child: InkWell(
                                                                                onTap: () async {
                                                                                  setState(() {
                                                                                    controller.clear();
                                                                                  });
                                                                                  await manuallyUpdateQuantity(items.indexOf(e), items, context, controller);
                                                                                },
                                                                                child: Container(color: Colors.transparent),
                                                                              )),
                                                                              Expanded(
                                                                                  child: InkWell(
                                                                                onTap: () async {
                                                                                  await setQunatity(items.indexOf(e), true, items, context);
                                                                                },
                                                                                child: Container(color: Colors.transparent),
                                                                              ))
                                                                            ],
                                                                          )
                                                                        ],
                                                                      )
                                                                    : InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          await setQunatity(
                                                                              items.indexOf(e),
                                                                              true,
                                                                              items,
                                                                              context);
                                                                        },
                                                                        child:
                                                                            Stack(
                                                                          alignment:
                                                                              Alignment.topRight,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "ADD",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(fontSize: 12, color: Colors.teal[900]),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(5.0),
                                                                              child: Icon(
                                                                                Icons.add,
                                                                                color: Colors.teal[900],
                                                                                size: 10,
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                          ),
                                                  ),
                                                ),
                                                // Positioned(
                                                //   top: 0,
                                                //   right: 0,
                                                //   child: e['is_favorite'] ==
                                                //           0
                                                //       ? SizedBox()
                                                //       : Padding(
                                                //           padding:
                                                //               const EdgeInsets
                                                //                   .all(8.0),
                                                //           child: Align(
                                                //             alignment:
                                                //                 Alignment
                                                //                     .topRight,
                                                //             child: Icon(
                                                //               Icons.star,
                                                //               color: Colors
                                                //                   .amber,
                                                //             ),
                                                //           ),
                                                //         ),
                                                // ),
                                                // inStock
                                                //     ? Container(
                                                //         width: 150,
                                                //         color: Colors.grey
                                                //             .withOpacity(
                                                //                 0.5),
                                                //         child: Center(
                                                //           // child: Image.asset(
                                                //           //   "assets/out-of-stock.png",
                                                //           //   scale: 10,
                                                //           //   color: Colors.black,
                                                //           // ),
                                                //           child: Container(
                                                //               width: MediaQuery.of(
                                                //                       context)
                                                //                   .size
                                                //                   .width,
                                                //               color: Colors
                                                //                       .grey[
                                                //                   700],
                                                //               child:
                                                //                   Padding(
                                                //                 padding:
                                                //                     const EdgeInsets.all(
                                                //                         8.0),
                                                //                 child: Text(
                                                //                   "Out-of-Stock",
                                                //                   textAlign:
                                                //                       TextAlign
                                                //                           .center,
                                                //                   style:
                                                //                       textStyle1,
                                                //                 ),
                                                //               )),
                                                //         ),
                                                //       )
                                                //     : SizedBox()
                                              ],
                                            );
                                          }).toList()),
                                        ),
                                      ),
                                      items.indexOf(e) == items.length - 2
                                          ? SizedBox()
                                          : Divider(
                                              color: Colors.grey[200],
                                              thickness: 15,
                                            ),
                                    ],
                                  );
                                }).toList(),
                              ),
                        Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              image: DecorationImage(
                                  alignment: Alignment(0.6, -0.15),
                                  scale: 10,
                                  image: AssetImage(
                                    "assets/emoji1.png",
                                  ))),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(18, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("didn't find\nwhat you were\nlooking for?",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.montserrat(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[400])),
                                SizedBox(
                                  height: 20,
                                ),
                                Text("Suggest something & we'll look into it",
                                    style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[400])),
                                SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    suggestProductBottom();
                                  },
                                  child: Container(
                                    child: Text("Suggest a Product",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.pink[700])),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        viewModel.counterShowCart
                            ? SizedBox(
                                height: 50,
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: viewModel.counterShowCart
                          ? bottomSheet()
                          : SizedBox())
                ],
              ));
        }),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddress(value) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    Placemark place = placemarks[0];
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString("pincode", place.postalCode.toString());
      pref.setString("address_type", place.subLocality.toString());

      pref.setString(
          "defaultAddress",
          place.subAdministrativeArea.toString() +
              " ," +
              place.name.toString() +
              " ," +
              place.subLocality.toString() +
              " ," +
              place.locality.toString() +
              " ," +
              place.postalCode.toString() +
              " ," +
              place.country.toString());
      defaultAddress = pref.getString("defaultAddress").toString();
      addressType = place.subLocality.toString();
      List temp = [
        {
          "address_type": place.subLocality.toString(),
          "address": defaultAddress,
          "pincode": place.postalCode.toString()
        }
      ];
      pref.setString("recent_address_list", jsonEncode(temp));
      Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
    });
  }

  TextEditingController productName = TextEditingController();
  TextEditingController brandName = TextEditingController();
  TextEditingController productQty = TextEditingController();
  GlobalKey<FormState> suggestForm = GlobalKey<FormState>();
  Future<void> suggestProductBottom() async {
    setState(() {
      productName.clear();
      brandName.clear();
      productQty.clear();
    });
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
                child: Form(
              key: suggestForm,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Suggest Products",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                        "Didn't find what you are lokking for? Please suggest the product",
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                    SizedBox(
                      height: 15,
                    ),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Color(0xFFEEEEEE))),
                      child: TextFormField(
                        controller: productName,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required Field';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.all(10),
                          // filled: true,
                          // fillColor: Colors.teal[50],
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.lightBlue),
                              borderRadius: BorderRadius.circular(10)),
                          hintText: "Suggested Product Name",
                          hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Color(0xFFEEEEEE))),
                            child: TextFormField(
                              controller: productQty,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required Field';
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                // filled: true,
                                // fillColor: Colors.teal[50],
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.lightBlue),
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "QTY",
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(color: Color(0xFFEEEEEE))),
                            child: TextFormField(
                              controller: brandName,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required Field';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: EdgeInsets.all(10),
                                // filled: true,
                                // fillColor: Colors.teal[50],
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.lightBlue),
                                    borderRadius: BorderRadius.circular(10)),
                                hintText: "Brand Name",
                                hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                          flex: 3,
                        )
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
                              if (suggestForm.currentState!.validate()) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Adding suggested product"),
                                  ),
                                );
                                OtherAPI()
                                    .requestProduct(
                                        productName.text.toString(),
                                        brandName.text.toString(),
                                        productQty.text.toString())
                                    .then((value) {
                                  if (value) {
                                    suggestProductBottomThankYou();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Product Suggestion Failed"),
                                      ),
                                    );
                                  }
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Please enter required fields"),
                                    duration: Duration(milliseconds: 500),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Send",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white),
                            ))),
                  ]),
            ))));
  }

  Future<void> suggestProductBottomThankYou() async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Text("Thank You!",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Image.asset(
                    "assets/balloons.png",
                    scale: 10,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text("We've received your suggestion.",
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 20,
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
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.teal[700])),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Done",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white),
                          ))),
                ]))));
  }
}
