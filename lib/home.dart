// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:convert';

// import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biz_sales_admin/UpdateCart.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:upgrader/upgrader.dart';

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
  bool isLoadingAllCategory = false;
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

  int count = 1;
  int last_page = 0;
  int last_count = 1;
  // Future<void> getCarouselsListData() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   if (pref.getBool("loggedIn") ?? false) {
  //     OtherAPI().carouselsWithLogin(count.toString()).then((value) {
  //       setState(() {
  //         alreadyCalled.add(count);
  //         // carouselsList.clear();
  //         carouselsList.addAll(value['data']);
  //         last_page = int.parse(value['last_page'].toString());
  //         isLoadingCarosole = false;
  //         isLoadingCarosoleLoadMore = false;
  //         count++;
  //       });
  //     });
  //   } else {
  //     OtherAPI().carouselsWithoutLogin(count.toString()).then((value) {
  //       setState(() {
  //         // carouselsList.clear();
  //         carouselsList.addAll(value['data']);
  //         last_page = int.parse(value['last_page'].toString());
  //         isLoadingCarosole = false;
  //         isLoadingCarosoleLoadMore = false;
  //         count++;
  //       });
  //     });
  //   }
  // }

  double currentIndexPage = 0;
  List bannerImagesList = [];
  String announcment = "";
  List recentOrderItems = [];
  String pinCode = '';
  bool isLoadingCarosoleLoadMore = false;
  bool backtotop = false;
  List alreadyCalled = [];
  void reloadApis() async {
    // setState(() {
    //   count = 1;
    //   last_page = 1;
    //   carouselsList.clear();
    // });
    // scrollController.addListener(() {
    //   if (scrollController.offset >=
    //           scrollController.position.maxScrollExtent &&
    //       !scrollController.position.outOfRange) {
    //     if (count <= last_page && !isLoadingCarosoleLoadMore) {
    //       setState(() {
    //         isLoadingCarosoleLoadMore = true;
    //       });
    //       getCarouselsListData();
    //     }
    //   }
    // });

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // //print(prefs.getString("token"));
    // setState(() {
    //   defaultAddress = prefs.getString("defaultAddress").toString();
    //   addressType = prefs.getString("subLocality").toString();
    //   pinCode = prefs.getString('pincode').toString();
    // });

    // Provider.of<UpdateCartData>(context, listen: false).checkForServiceable();

    // OtherAPI().homePageBanner("header").then((value) {
    //   setState(() {
    //     announcment = "";
    //     announcment = value[0]['mobile_banner'].toString();
    //   });
    // });
    // OtherAPI().homePageBanner("slider").then((value) {
    //   setState(() {
    //     bannerImagesList.clear();
    //     bannerImagesList.addAll(value);
    //   });
    // });
    // CategoryAPI().cartegoryList().then((value) {
    //   setState(() {
    //     categoryList.clear();
    //     categoryList.addAll(value);
    //     isLoadingAllCategory = false;
    //   });
    // });

    // getCarouselsListData();
    // Provider.of<UpdateCartData>(context, listen: false).counterShowCart;
    // CartAPI().recentOrderItems().then((value) {
    //   setState(() {
    //     recentOrderItems.clear();
    //     recentOrderItems.addAll(value);
    //   });
    // });
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

        return true;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoadingAllCategory = true;
            isLoadingCarosole = true;
            isLoadingCarosoleLoadMore = false;
          });
          reloadApis();
          // _determinePosition().then(
          //   (value) {
          //     _getAddress(value).then((value) {

          //     });
          //   },
          // );
        },
        child: SafeArea(
          child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
            return Scaffold(
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
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             AddressListScreen(
                                      //               m: {},
                                      //             ))).then((value) async {
                                      //   // SharedPreferences pref =
                                      //   //     await SharedPreferences
                                      //   //         .getInstance();

                                      //   // setState(() {
                                      //   //   addressType = pref
                                      //   //       .getString("address_type")
                                      //   //       .toString();
                                      //   //   defaultAddress = pref
                                      //   //       .getString("defaultAddress")
                                      //   //       .toString();
                                      //   // });
                                      // });
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
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    announcment == "" || announcment == null
                                        ? SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                    bannerImagesList.isEmpty
                                        ? SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Align(
                          //     alignment: Alignment.bottomCenter,
                          //     child: viewModel.counterShowCart
                          //         ? bottomSheet()
                          //         : SizedBox())
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

      pref.setString("defaultAddress",
          "${place.subAdministrativeArea} ,${place.name} ,${place.subLocality} ,${place.locality} ,${place.postalCode} ,${place.country}");
      pref.setString("subLocality", place.subLocality.toString());
      List temp = [
        {
          "address_type": place.subLocality.toString(),
          "address":
              "${place.subAdministrativeArea} ,${place.name} ,${place.subLocality} ,${place.locality} ,${place.postalCode} ,${place.country}",
          "pincode": place.postalCode.toString()
        }
      ];
      pref.setString("recent_address_list", jsonEncode(temp));
      Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
    });
  }
}
