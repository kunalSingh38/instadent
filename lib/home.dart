// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:convert';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  Future<void> getCarouselsListData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      OtherAPI().carouselsWithLogin().then((value) {
        setState(() {
          carouselsList.clear();
          carouselsList.addAll(value);
          isLoadingCarosole = false;
          print(carouselsList.length.toString() + "test");
        });
      });
    }
    // else {
    //   OtherAPI().carouselsWithoutLogin().then((value) {
    //     setState(() {
    //       carouselsList.clear();
    //       carouselsList.addAll(value);
    //       isLoadingCarosole = false;
    //     });
    //   });
    // }
  }

  double currentIndexPage = 0;
  List bannerImagesList = [];
  String announcment = "";

  List recentOrderItems = [];

  void reloadApis() async {
    OtherAPI().homePageBanner("content").then((value) {
      print(value);
      setState(() {
        announcment = "";
        announcment = value[0]['mobile_banner'].toString();
      });
    });
    OtherAPI().homePageBanner("header").then((value) {
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
    getAddressList();
    getCarouselsListData();
    Provider.of<UpdateCartData>(context, listen: false).counterShowCart;
    CartAPI().recentOrderItems().then((value) {
      print(value[0]);
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
    // TODO: implement initState
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
      child: LiquidPullToRefresh(
        animSpeedFactor: 5,
        showChildOpacityTransition: true,
        springAnimationDurationInMilliseconds: 800,
        onRefresh: () async {
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
                    ? Center(
                        child: loadingProducts("We are getting your products"),
                      )
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 15, 0),
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
                                                      .replaceAll(" ,", ", "),
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
                                StickyHeader(
                                  header: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10))),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 10),
                                          child: onlySearch(),
                                        )),
                                  ),
                                  content: Column(
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      announcment == "" || announcment == null
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.grey[50]),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 15),
                                                    child: SizedBox(
                                                      height: 90,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              0.5,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: cacheImage(
                                                              announcment
                                                                  .toString())),
                                                    ),
                                                  )),
                                            ),
                                      // SizedBox(
                                      //   height: 5,
                                      // ),
                                      bannerImagesList.length == 0
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.grey[50]),
                                                child: ImageSlideshow(
                                                  width: double.infinity,
                                                  height: 180,
                                                  initialPage: 0,
                                                  indicatorColor: Colors.black,
                                                  indicatorBackgroundColor:
                                                      Colors.grey,
                                                  children: bannerImagesList
                                                      .map((e) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 22),
                                                            child: SizedBox(
                                                              height: 140,
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
                                                                      e['mobile_banner']
                                                                          .toString())),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onPageChanged: (value) {},
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
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            categoryList.length == 0
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                        "No products category available"),
                                                  )
                                                : seeMore
                                                    ? categoryList.length > 8
                                                        ? allCategoryGrid(
                                                            categoryList
                                                                .sublist(0, 8),
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
                                            categoryList.length == 0
                                                ? SizedBox()
                                                : categoryList.length <= 8
                                                    ? SizedBox()
                                                    : InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            seeMore = !seeMore;
                                                          });
                                                        },
                                                        child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .teal[100],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(12),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      seeMore
                                                                          ? "See more categories"
                                                                          : "See less categories",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  seeMore
                                                                      ? Icon(
                                                                          Icons
                                                                              .keyboard_arrow_down,
                                                                          size:
                                                                              15,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .keyboard_arrow_up,
                                                                          size:
                                                                              15,
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
                                      recentOrderItems.length == 0
                                          ? SizedBox()
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Recent Orders"
                                                              .toString(),
                                                          style: GoogleFonts
                                                              .montserrat(
                                                                  fontSize: 16,
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
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          15, 0, 15, 10),
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                            children:
                                                                recentOrderItems
                                                                    .map((e) {
                                                          bool inStock =
                                                              e['is_stock'] == 1
                                                                  ? false
                                                                  : true;

                                                          String disccount =
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
                                                    color: Colors.grey[200],
                                                    thickness: 10,
                                                  ),
                                                ]),
                                      carouselsList.length == 0
                                          ? SizedBox()
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: carouselsList.map((e) {
                                                if (e['type'].toString() ==
                                                    "banner_carousel") {
                                                  List items = e['items'];

                                                  return items.length == 0
                                                      ? SizedBox()
                                                      : Column(
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                            .grey[
                                                                        50]),
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
                                                          ],
                                                        );
                                                } else {
                                                  List items = e['items'];

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
                                                              style: GoogleFonts
                                                                  .montserrat(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800),
                                                            ),
                                                            Text(
                                                              items.length
                                                                      .toString() +
                                                                  " products",
                                                              style: GoogleFonts.montserrat(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  fontSize: 12,
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
                                                                15, 0, 15, 10),
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                              children: items
                                                                  .map((e) {
                                                            bool inStock =
                                                                e['is_stock'] ==
                                                                        1
                                                                    ? false
                                                                    : true;

                                                            String disccount =
                                                                "";
                                                            String temp =
                                                                e['item_discount']
                                                                    .toString()
                                                                    .split(
                                                                        "%")[0];

                                                            if (temp
                                                                        .split(".")[
                                                                            0]
                                                                        .toString() ==
                                                                    "0" &&
                                                                temp
                                                                        .split(
                                                                            ".")[1]
                                                                        .toString() ==
                                                                    "00") {
                                                              disccount = "0";
                                                            } else if (temp
                                                                    .split(
                                                                        ".")[1]
                                                                    .toString() ==
                                                                "00") {
                                                              disccount = temp
                                                                  .split(".")[0]
                                                                  .toString();
                                                            } else {
                                                              disccount = temp;
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
                                                      items.indexOf(e) ==
                                                              items.length - 2
                                                          ? SizedBox()
                                                          : Divider(
                                                              color: Colors
                                                                  .grey[200],
                                                              thickness: 10,
                                                            ),
                                                    ],
                                                  );
                                                }
                                              }).toList(),
                                            ),
                                      Container(
                                        height: 300,
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                              Text("didn't find\nwhat you were",
                                                  textAlign: TextAlign.left,
                                                  style: GoogleFonts.montserrat(
                                                      fontSize:
                                                          unitHeightValue * 2.3,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.grey[400])),
                                              Row(
                                                children: [
                                                  Text("looking for?",
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts
                                                          .montserrat(
                                                              fontSize:
                                                                  unitHeightValue *
                                                                      2.3,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Colors
                                                                  .grey[400])),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Image.asset(
                                                      "assets/emoji1.png",
                                                      scale:
                                                          unitHeightValue * 0.7)
                                                ],
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                  "Suggest something & we'll look into it",
                                                  style: GoogleFonts.montserrat(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.grey[400])),
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
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .pink[700])),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.grey)),
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
}
