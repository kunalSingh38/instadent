// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/main.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:http/http.dart' as http;
import 'banner_products_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchCont = TextEditingController();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  GlobalKey key = GlobalKey();
  String defaultAddress = "Select Address";
  String addressType = "Other";
  // List addressList = [];
  bool isLoadingAllCategory = true;
  bool isLoadingCarosole = true;

  // Future<void> getAddressList() async {
  //   _determinePosition().then((value) {
  //     _getAddress(value).then((value) =>
  //         Provider.of<UpdateCartData>(context, listen: false)
  //             .checkForServiceable());
  //   });
  // }

  Widget onlySearch() => InkWell(
        onTap: () {
          Provider.of<UpdateCartData>(context, listen: false)
              .changeSearchView(2);
        },
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
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
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400),
                      ))
                ],
              ),
            )),
      );

  ScrollController scrollController = ScrollController();
  double scrollOffset = 0;
  List categoryList = [];
  TextEditingController controller = TextEditingController();
  bool seeMore = true;
  List carouselsList = [];
  ImageProvider bottomText = AssetImage("assets/instaCircle.png");
  ImageProvider topImage = AssetImage("assets/instavalue.png");
  Future<void> getCarouselsListData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      OtherAPI().carouselsWithLogin().then((value) {
        setState(() {
          carouselsList.clear();
          carouselsList.addAll(value);
          isLoadingCarosole = false;
        });
      });
    } else {
      OtherAPI().carouselsWithoutLogin().then((value) {
        setState(() {
          carouselsList.clear();
          carouselsList.addAll(value);
          isLoadingCarosole = false;
        });
      });
    }
  }

  double currentIndexPage = 0;
  List bannerImagesList = [];
  String announcment = "";
  List recentOrderItems = [];
  String pinCode = '';

  void reloadApis() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pinCode = prefs.getString('pincode').toString();
    print("pincode--->$pinCode");
    setState(() {
      defaultAddress = prefs.getString("defaultAddress").toString();
      addressType = prefs.getString("subLocality").toString();
    });
    // if (pinCode == null || pinCode == "" || pinCode == "null") {
    //   // getAddressList();
    // } else {
    Provider.of<UpdateCartData>(context, listen: false).checkForServiceable();
    // }

    OtherAPI().homePageBanner("header").then((value) {
      setState(() {
        announcment = "";
        announcment = value[0]['mobile_banner'].toString();
      });
    });
    OtherAPI().homePageBanner("slider").then((value) {
      setState(() {
        bannerImagesList.clear();
        bannerImagesList.addAll(value);
      });
    });
    CategoryAPI().cartegoryList().then((value) {
      setState(() {
        categoryList.clear();
        categoryList.addAll(value);
        isLoadingAllCategory = false;
      });
    });
    getCarouselsListData();
    Provider.of<UpdateCartData>(context, listen: false).counterShowCart;
    CartAPI().recentOrderItems().then((value) {
      setState(() {
        recentOrderItems.clear();
        recentOrderItems.addAll(value);
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    reloadApis();
  }

  // bool showSearch = false;
  @override
  Widget build(BuildContext context) {
    double unitHeightValue =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.02
            : MediaQuery.of(context).size.width * 0.02;
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) => Dialog(
                  backgroundColor: Colors.transparent.withOpacity(0),
                  elevation: 0,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Image.asset("assets/exit.png"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.grey[200])),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "CANCEL",
                                  style: TextStyle(color: Colors.black),
                                )),
                          )),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.blue[800])),
                                onPressed: () {
                                  SystemNavigator.pop();
                                },
                                child: Text("CONFIRM",
                                    style: TextStyle(color: Colors.white))),
                          )),
                        ],
                      )
                    ],
                  ),
                ));
        // showDialog(
        //     context: context,
        //     builder: (context) => Container(
        //         height: MediaQuery.of(context).size.height * 0.4,
        //         width: MediaQuery.of(context).size.width,
        //         child: Stack(
        //           children: [
        //             Dialog(
        //               backgroundColor: Colors.white,
        //               child: SizedBox(
        //                 height: MediaQuery.of(context).size.height * 0.06,
        //                 width: MediaQuery.of(context).size.width * 0.99,
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   children: [
        //                     SizedBox(
        //                       height:
        //                           MediaQuery.of(context).size.height * 0.055,
        //                     ),
        //                     Container(
        //                       height:
        //                           MediaQuery.of(context).size.height * 0.055,
        //                       decoration: BoxDecoration(
        //                           image: DecorationImage(image: topImage)),
        //                     ),
        //                     Text("Thanks for visiting",
        //                         style: TextStyle(
        //                             color: Colors.teal,
        //                             fontWeight: FontWeight.w500)),
        //                     Container(
        //                       alignment: Alignment.center,
        //                       width: MediaQuery.of(context).size.width,
        //                       child: Text(
        //                         "Please confirm if you want to exit?",
        //                         style: TextStyle(
        //                             color: Colors.grey[700],
        //                             fontSize: 13,
        //                             fontWeight: FontWeight.w600),
        //                         maxLines: 1,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //               // actionsAlignment: MainAxisAlignment.spaceAround,
        //               // actionsPadding: EdgeInsets.only(bottom: 10),
        //               // actions: [
        //               //   Container(
        //               //     height: MediaQuery.of(context).size.height * 0.04,
        //               //     width: MediaQuery.of(context).size.width * 0.3,
        //               //     decoration: BoxDecoration(
        //               //         color: Colors.grey[200],
        //               //         borderRadius: BorderRadius.circular(5)),
        //               //     child: TextButton(
        //               //         onPressed: () {
        //               //           Navigator.of(context).pop();
        //               //         },
        //               //         child: Text(
        //               //           "Cancel",
        //               //           style: TextStyle(color: Colors.black),
        //               //         )),
        //               //   ),
        //               //   Container(
        //               //     height: MediaQuery.of(context).size.height * 0.044,
        //               //     width: MediaQuery.of(context).size.width * 0.3,
        //               //     decoration: BoxDecoration(
        //               //         color: Colors.blue[800],
        //               //         borderRadius: BorderRadius.circular(5)),
        //               //     child: TextButton(
        //               //         onPressed: () {
        //               //           SystemNavigator.pop();
        //               //         },
        //               //         child: Text(
        //               //           "Confirm",
        //               //           style: TextStyle(color: Colors.white),
        //               //         )),
        //               //   ),
        //               // ],
        //             ),
        //             Positioned(
        //               left: MediaQuery.of(context).size.width * 0.37,
        //               top: MediaQuery.of(context).size.height * 0.27,
        //               child: Container(
        //                 alignment: Alignment.center,
        //                 height: 100,
        //                 width: 100,
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(100),
        //                   color: Colors.white,
        //                 ),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     Container(
        //                       height: 80,
        //                       width: 80,
        //                       decoration: BoxDecoration(
        //                           image: DecorationImage(image: bottomText)),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         )));
        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoadingAllCategory = true;
          });
          reloadApis();
        },
        child: SafeArea(
          child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
            return Scaffold(
                // appBar: showSearch
                //     ? AppBar(
                //         toolbarHeight: 60,
                //         backgroundColor: Colors.white,
                //         elevation: 8,
                //         title: onlySearch(),
                //       )
                //     : null,
                extendBodyBehindAppBar: true,
                body: isLoadingAllCategory
                    ? loadingProducts("Please Wait...")
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        15, 15, 15, 0),
                                    child: viewModel.counterServicable
                                        ? Text(
                                            "Delivery " +
                                                viewModel.counterDeliveryTime
                                                    .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18))
                                        : Text(
                                            viewModel.counterDeliveryTime
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18))),
                                SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddressListScreen(
                                                    m: {},
                                                  ))).then((value) async {
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
                                          flex: 20,
                                          child: Text(
                                              viewModel.counterDefaultOffice
                                                      .toString()
                                                      .toUpperCase() +
                                                  ", " +
                                                  viewModel
                                                      .counterDefaultAddress
                                                      .toString()
                                                      .replaceAll(",", ""),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                        ),
                                        Expanded(
                                            child: Icon(Icons.arrow_drop_down))
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                viewModel.counterServicable
                                    ? StickyHeader(
                                        header: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 10),
                                                child: onlySearch(),
                                              )),
                                        ),
                                        content: Column(
                                          children: [
                                            SizedBox(
                                              height: 15,
                                            ),
                                            announcment == "" ||
                                                    announcment == null
                                                ? SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color: Colors
                                                                .grey[50]),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 15),
                                                          child: SizedBox(
                                                            height: 90,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                0.5,
                                                            child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child: cacheImage(
                                                                    announcment
                                                                        .toString())),
                                                          ),
                                                        )),
                                                  ),
                                            // SizedBox(
                                            //   height: 5,
                                            // ),
                                            bannerImagesList.isEmpty
                                                ? SizedBox()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color:
                                                              Colors.grey[50]),
                                                      child: ImageSlideshow(
                                                        width: double.infinity,
                                                        height: 180,
                                                        initialPage: 0,
                                                        indicatorColor:
                                                            Colors.black,
                                                        indicatorBackgroundColor:
                                                            Colors.grey,
                                                        children:
                                                            bannerImagesList
                                                                .map(
                                                                    (e) =>
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.only(bottom: 22),
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                140,
                                                                            width:
                                                                                MediaQuery.of(context).size.width / 0.5,
                                                                            child:
                                                                                ClipRRect(borderRadius: BorderRadius.circular(10), child: cacheImage(e['mobile_banner'].toString())),
                                                                          ),
                                                                        ))
                                                                .toList(),
                                                        onPageChanged:
                                                            (value) {},
                                                        autoPlayInterval: 4000,
                                                        isLoop: true,
                                                      ),
                                                    ),
                                                  ),
                                            // SizedBox(
                                            //   height: 20,
                                            // ),
                                            Divider(
                                              color: Colors.grey[200],
                                              thickness: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(15),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Shop by category",
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  categoryList.isEmpty
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "No products category available"),
                                                        )
                                                      : seeMore
                                                          ? categoryList
                                                                      .length >
                                                                  8
                                                              ? allCategoryGrid(
                                                                  categoryList
                                                                      .sublist(
                                                                          0, 8),
                                                                  context,
                                                                  unitHeightValue)
                                                              : allCategoryGrid(
                                                                  categoryList.sublist(
                                                                      0,
                                                                      categoryList
                                                                          .length),
                                                                  context,
                                                                  unitHeightValue)
                                                          : allCategoryGrid(
                                                              categoryList,
                                                              context,
                                                              unitHeightValue),
                                                  categoryList.isEmpty
                                                      ? SizedBox()
                                                      : categoryList.length <= 8
                                                          ? SizedBox()
                                                          : InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  seeMore =
                                                                      !seeMore;
                                                                });
                                                              },
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .teal[
                                                                          100],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            12),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                            seeMore
                                                                                ? "Show more categories"
                                                                                : "Show less categories",
                                                                            style:
                                                                                TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                                        seeMore
                                                                            ? Icon(
                                                                                Icons.keyboard_arrow_down,
                                                                                size: 15,
                                                                              )
                                                                            : Icon(
                                                                                Icons.keyboard_arrow_up,
                                                                                size: 15,
                                                                              )
                                                                      ],
                                                                    ),
                                                                  )),
                                                            )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.grey[200],
                                              thickness: 10,
                                            ),
                                            recentOrderItems.isEmpty
                                                ? SizedBox()
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                "Recent Orders"
                                                                    .toString(),
                                                                style: GoogleFonts.montserrat(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800),
                                                              ),
                                                              Text(
                                                                recentOrderItems
                                                                        .length
                                                                        .toString() +
                                                                    " products",
                                                                style: GoogleFonts.montserrat(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    15,
                                                                    0,
                                                                    15,
                                                                    10),
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Row(
                                                                  children:
                                                                      recentOrderItems
                                                                          .map(
                                                                              (e) {
                                                                bool inStock =
                                                                    e['is_stock'] ==
                                                                            1
                                                                        ? false
                                                                        : true;

                                                                String
                                                                    disccount =
                                                                    e['discount_percentage']
                                                                        .toString();

                                                                // if (temp
                                                                //             .split(".")[
                                                                //                 0]
                                                                //             .toString() ==
                                                                //         "0" &&
                                                                //     temp
                                                                //             .split(
                                                                //                 ".")[1]
                                                                //             .toString() ==
                                                                //         "00") {
                                                                //   disccount = "0";
                                                                // } else if (temp
                                                                //         .split(".")[1]
                                                                //         .toString() ==
                                                                //     "00") {
                                                                //   disccount = temp
                                                                //       .split(".")[0]
                                                                //       .toString();
                                                                // } else {
                                                                //   disccount = temp;
                                                                // }
                                                                // return Text("data");
                                                                return singleProductDesign(
                                                                    context,
                                                                    e,
                                                                    inStock,
                                                                    controller,
                                                                    recentOrderItems,
                                                                    dynamicLinks,
                                                                    disccount,
                                                                    true);
                                                              }).toList()),
                                                            )),
                                                        Divider(
                                                          color:
                                                              Colors.grey[200],
                                                          thickness: 10,
                                                        ),
                                                      ]),
                                            isLoadingCarosole
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 50),
                                                    child: loadingProducts(
                                                        "Loading..."),
                                                  )
                                                : carouselsList.isEmpty
                                                    ? SizedBox()
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: carouselsList
                                                            .map((e) {
                                                          if (e['type']
                                                                  .toString() ==
                                                              "banner_carousel") {
                                                            List items =
                                                                e['items'];

                                                            return items.isEmpty
                                                                ? SizedBox()
                                                                : Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (e['banner_items'] ==
                                                                              true) {
                                                                            Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => BannerProductsView(
                                                                                          id: e['id'].toString(),
                                                                                        )));
                                                                          }
                                                                        },
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(horizontal: 15),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey[50]),
                                                                            child: ImageSlideshow(
                                                                                width: double.infinity,
                                                                                height: 180,
                                                                                initialPage: 0,
                                                                                indicatorColor: items.length == 1 ? Colors.white : Colors.black,
                                                                                indicatorBackgroundColor: Colors.grey,
                                                                                children: items
                                                                                    .map((e) => Padding(
                                                                                          padding: const EdgeInsets.only(bottom: 22),
                                                                                          child: SizedBox(
                                                                                            height: 140,
                                                                                            width: MediaQuery.of(context).size.width / 0.5,
                                                                                            child: ClipRRect(borderRadius: BorderRadius.circular(10), child: cacheImage(e['mobile_banner'].toString())),
                                                                                          ),
                                                                                        ))
                                                                                    .toList(),
                                                                                onPageChanged: (value) {},
                                                                                autoPlayInterval: 4000,
                                                                                isLoop: items.length == 1 ? false : true),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                          } else {
                                                            List items =
                                                                e['items'];

                                                            return Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(15),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        e['carousel_name']
                                                                            .toString(),
                                                                        style: GoogleFonts.montserrat(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w800),
                                                                      ),
                                                                      Text(
                                                                        items.length.toString() +
                                                                            " products",
                                                                        style: GoogleFonts.montserrat(
                                                                            decoration: TextDecoration
                                                                                .underline,
                                                                            fontSize:
                                                                                12,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .fromLTRB(
                                                                          15,
                                                                          0,
                                                                          15,
                                                                          10),
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                        children:
                                                                            items.map((e) {
                                                                      bool inStock = e['is_stock'] ==
                                                                              1
                                                                          ? false
                                                                          : true;

                                                                      String
                                                                          disccount =
                                                                          "";
                                                                      String temp = e[
                                                                              'item_discount']
                                                                          .toString()
                                                                          .split(
                                                                              "%")[0];

                                                                      if (temp.split(".")[0].toString() ==
                                                                              "0" &&
                                                                          temp.split(".")[1].toString() ==
                                                                              "00") {
                                                                        disccount =
                                                                            "0";
                                                                      } else if (temp
                                                                              .split(".")[1]
                                                                              .toString() ==
                                                                          "00") {
                                                                        disccount = temp
                                                                            .split(".")[0]
                                                                            .toString();
                                                                      } else {
                                                                        disccount =
                                                                            temp;
                                                                      }
                                                                      return singleProductDesign(
                                                                          context,
                                                                          e,
                                                                          inStock,
                                                                          controller,
                                                                          items,
                                                                          dynamicLinks,
                                                                          disccount,
                                                                          true);
                                                                    }).toList()),
                                                                  ),
                                                                ),
                                                                items.indexOf(
                                                                            e) ==
                                                                        items.length -
                                                                            2
                                                                    ? SizedBox()
                                                                    : Divider(
                                                                        color: Colors
                                                                            .grey[200],
                                                                        thickness:
                                                                            10,
                                                                      ),
                                                              ],
                                                            );
                                                          }
                                                        }).toList(),
                                                      ),
                                            Container(
                                              height: 300,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                // image: DecorationImage(
                                                //     alignment: Alignment(0.6, -0.15),
                                                //     scale: 10,
                                                //     image: AssetImage(
                                                //       "assets/emoji1.png",
                                                //     ))
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    18, 20, 20, 20),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "didn't find\nwhat you were",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize:
                                                                    unitHeightValue *
                                                                        2.3,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    Colors.grey[
                                                                        400])),
                                                    Row(
                                                      children: [
                                                        Text("looking for?",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts.montserrat(
                                                                fontSize:
                                                                    unitHeightValue *
                                                                        2.3,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color:
                                                                    Colors.grey[
                                                                        400])),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Image.asset(
                                                            "assets/emoji1.png",
                                                            scale:
                                                                unitHeightValue *
                                                                    0.7)
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                        "Suggest something & we'll look into it",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors.grey[
                                                                        400])),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        suggestProductBottom();
                                                      },
                                                      child: Container(
                                                        child: Text(
                                                            "Suggest a Product",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    fontSize:
                                                                        13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                            .pink[
                                                                        700])),
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.white70,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey)),
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
                                      )
                                    : Column(
                                        children: [
                                          // Container(
                                          //     alignment: Alignment.center,
                                          //     child: Text(
                                          //         "Store is not associated with service area")),
                                          Image.asset(
                                            "assets/instadent service.jpg",
                                            scale: 1,
                                          ),
                                        ],
                                      )
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
      ),
    );
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
                        "Didn't find what you are looking for? Please suggest the product",
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
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text("Adding suggested product"),
                                //   ),
                                // );
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

  // String getItemResponse = '';
  // int dataAccess = 0;
  // bool getAcess = false;
  // Future getAccessDetails() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   String currentPincode = pref.getString("pincode").toString();
  //   var url = URL + "pincode-estimate-delivery";
  //   var body = {
  //     "pincode": currentPincode,
  //   };
  //   var response = await http.post(
  //     Uri.parse(url),
  //     body: jsonEncode(body),
  //     headers: {'Content-Type': 'application/json'},
  //   );

  //   log("body---->" + body.toString());

  //   var result = jsonDecode(response.body);
  //   dataAccess = result['ErrorCode'];
  //   if (dataAccess == 0) {
  //     getItemResponse =
  //         result['ItemResponse']['delivery_expected_time'].toString();
  //     log("item response--->$getItemResponse");
  //     var snackBar = SnackBar(
  //       content: Text(result['ErrorMessage']),
  //     );
  //     // ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   } else {
  //     setState(() {
  //       getAcess = true;
  //     });

  //     var snackBar = SnackBar(
  //       content: Text(result['ErrorMessage']),
  //     );
  //     ScaffoldMessenger.of(context).showSnackBar(snackBar);
  //   }
  // }
}
