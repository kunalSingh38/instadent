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
  bool isLoading = true;
  Future<void> getAddressList() async {
    _determinePosition().then((value) {
      _getAddress(value);
    });
  }

  Widget searchCard() => Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Color(0xFFEEEEEE))),
        child: TextFormField(
          controller: searchCont,
          readOnly: true,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SearchScreen()));
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.all(2),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(10)),
            hintText: "Search for atta, dal, coke and more",
            hintStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.w300),
            prefixIcon: Padding(
                padding: const EdgeInsets.all(5),
                child: Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 35,
                )),
          ),
        ),
      );

  ScrollController scrollController = ScrollController();
  double scrollOffset = 0;
  List categoryList = [];

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

    getAddressList();
    // scrollController.addListener(() {
    //   scrollOffset = double.parse(scrollController.offset.toString());
    //   setState(() {});
    // });
    CategoryAPI().cartegoryList().then((value) {
      setState(() {
        categoryList.clear();
        categoryList.addAll(value);
      });
    });
  }

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
        child: ModalProgressHUD(
          inAsyncCall: isLoading,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: scrollOffset > 81.5
                ? AppBar(
                    backgroundColor: Colors.white,
                    toolbarHeight: 60,
                    title: searchCard())
                : null,
            bottomSheet: bottomSheet(),
            body:
                Consumer<UpdateCartData>(builder: (context, viewModel, child) {
              return Padding(
                padding:
                    EdgeInsets.only(bottom: viewModel.counterShowCart ? 70 : 0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Delivery in 11 mintues",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w800, fontSize: 20)),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddressListScreen()))
                                      .then((value) async {
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();

                                    setState(() {
                                      addressType = pref
                                          .getString("address_type")
                                          .toString();
                                      defaultAddress = pref
                                          .getString("defaultAddress")
                                          .toString();
                                    });
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 15,
                                      child: Text(
                                          addressType +
                                              ", " +
                                              defaultAddress.toString(),
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
                              height: 15,
                            ),
                            searchCard(),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.teal[100]),
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
                            SizedBox(
                              height: 15,
                            ),
                            GridView.count(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.6,
                              physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: categoryList
                                  .map((e) => InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SubCategoriesScreen(
                                                        catName:
                                                            e['category_name']
                                                                .toString(),
                                                        catId:
                                                            e['id'].toString(),
                                                      ))).then((value) {
                                            Provider.of<UpdateCartData>(context,
                                                    listen: false)
                                                .incrementCounter();
                                            Provider.of<UpdateCartData>(context,
                                                    listen: false)
                                                .showCartorNot();
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          Colors.tealAccent[50],
                                                    ),
                                                    child: e['icon'] == null
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: Image.asset(
                                                              "assets/no_image.jpeg",
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                Image.network(
                                                              e['icon']
                                                                  .toString(),
                                                              fit: BoxFit.cover,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null)
                                                                  return child;
                                                                return Center(
                                                                    child:
                                                                        Container(
                                                                  color: Colors
                                                                      .white,
                                                                ));
                                                              },
                                                            ),
                                                          ))),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                                child: Text(
                                              e['category_name'] == ""
                                                  ? "No Name"
                                                  : e['category_name']
                                                      .toString(),
                                              softWrap: true,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ))
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            )
                          ],
                        ),
                      ),
                      // Divider(
                      //   thickness: 10,
                      //   color: Colors.grey[200],
                      // ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      // GridView.count(
                      //   padding: EdgeInsets.zero,
                      //   crossAxisCount: 2,
                      //   mainAxisSpacing: 0,
                      //   crossAxisSpacing: 0,
                      //   childAspectRatio: 0.8,
                      //   physics: ClampingScrollPhysics(),
                      //   scrollDirection: Axis.vertical,
                      //   shrinkWrap: true,
                      //   children: List.generate(
                      //     6,
                      //     (index) => Stack(
                      //       children: [
                      //         InkWell(
                      //           onTap: () async {},
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //                 border: Border.all(
                      //                     color: Color(0xFFD6D6D6), width: 0.3)),
                      //             child: Column(
                      //               children: [
                      //                 Expanded(
                      //                   child: Container(
                      //                       child: Image.asset("assets/logo.png")),
                      //                 ),
                      //                 SizedBox(
                      //                   height: 5,
                      //                 ),
                      //                 Expanded(
                      //                     child: Padding(
                      //                   padding: const EdgeInsets.fromLTRB(
                      //                       10, 15, 8, 10),
                      //                   child: Column(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Text(
                      //                         "Potato + Onion",
                      //                         textAlign: TextAlign.left,
                      //                         overflow: TextOverflow.ellipsis,
                      //                         maxLines: 2,
                      //                         style: TextStyle(
                      //                             fontWeight: FontWeight.w500,
                      //                             fontSize: 12),
                      //                       ),
                      //                       Text(
                      //                         "500 g",
                      //                         textAlign: TextAlign.left,
                      //                         maxLines: 1,
                      //                         style: TextStyle(
                      //                             fontWeight: FontWeight.w300,
                      //                             fontSize: 12),
                      //                       ),
                      //                       SizedBox(
                      //                         height: 10,
                      //                       ),
                      //                       Row(
                      //                         mainAxisAlignment:
                      //                             MainAxisAlignment.spaceBetween,
                      //                         children: [
                      //                           Column(
                      //                             crossAxisAlignment:
                      //                                 CrossAxisAlignment.start,
                      //                             children: [
                      //                               Text("₹42",
                      //                                   //  +
                      //                                   //     e['discount_price']
                      //                                   //         .toString()
                      //                                   //         .split(".")[0],
                      //                                   style: TextStyle(
                      //                                       fontWeight:
                      //                                           FontWeight.w700,
                      //                                       fontSize: 12)),
                      //                               Text("₹50",
                      //                                   // +
                      //                                   //     e['item_price']
                      //                                   //         .toString()
                      //                                   //         .split(".")[0],
                      //                                   style: TextStyle(
                      //                                       fontWeight:
                      //                                           FontWeight.w400,
                      //                                       fontSize: 11,
                      //                                       decoration:
                      //                                           TextDecoration
                      //                                               .lineThrough,
                      //                                       color: Colors.grey))
                      //                             ],
                      //                           ),
                      //                         ],
                      //                       )
                      //                     ],
                      //                   ),
                      //                 ))
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //         Padding(
                      //           padding: const EdgeInsets.only(top: 12),
                      //           child: Container(
                      //             width: 70,
                      //             decoration: BoxDecoration(
                      //                 color: Colors.teal,
                      //                 borderRadius: BorderRadius.only(
                      //                     topRight: Radius.circular(10),
                      //                     bottomRight: Radius.circular(10))),
                      //             child: Padding(
                      //               padding: const EdgeInsets.all(2.0),
                      //               child: Text(
                      //                 "25% OFF",
                      //                 style: TextStyle(
                      //                     fontSize: 12,
                      //                     color: Colors.white,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //         Align(
                      //           alignment: Alignment.bottomRight,
                      //           child: Padding(
                      //             padding:
                      //                 const EdgeInsets.only(bottom: 15, right: 10),
                      //             child: Container(
                      //               width: 75,
                      //               height: 28,
                      //               decoration: BoxDecoration(
                      //                   color: 0 > 0
                      //                       ? Colors.teal[400]
                      //                       : Colors.teal[50],
                      //                   border:
                      //                       Border.all(color: Color(0xFF004D40)),
                      //                   borderRadius: BorderRadius.circular(10)),
                      //               child: 0 > 0
                      //                   ? Stack(
                      //                       children: [
                      //                         Row(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.spaceBetween,
                      //                           children: [
                      //                             Padding(
                      //                               padding:
                      //                                   const EdgeInsets.fromLTRB(
                      //                                       8, 4, 2, 4),
                      //                               child: Text(
                      //                                 "-",
                      //                                 style: textStyle1,
                      //                               ),
                      //                             ),
                      //                             Text(
                      //                               "0",
                      //                               style: textStyle1,
                      //                             ),
                      //                             Padding(
                      //                               padding:
                      //                                   const EdgeInsets.fromLTRB(
                      //                                       2, 4, 8, 4),
                      //                               child: Text(
                      //                                 "+",
                      //                                 style: textStyle1,
                      //                               ),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                         Row(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.spaceBetween,
                      //                           children: [
                      //                             Expanded(
                      //                                 child: InkWell(
                      //                               onTap: () async {},
                      //                               child: Container(
                      //                                 color: Colors.transparent,
                      //                               ),
                      //                             )),
                      //                             Expanded(
                      //                                 child: InkWell(
                      //                               onTap: () async {},
                      //                               child: Container(
                      //                                   color: Colors.transparent),
                      //                             )),
                      //                             Expanded(
                      //                                 child: InkWell(
                      //                               onTap: () async {},
                      //                               child: Container(
                      //                                   color: Colors.transparent),
                      //                             ))
                      //                           ],
                      //                         )
                      //                       ],
                      //                     )
                      //                   : InkWell(
                      //                       onTap: () async {},
                      //                       child: Stack(
                      //                         alignment: Alignment.topRight,
                      //                         children: [
                      //                           Padding(
                      //                             padding:
                      //                                 const EdgeInsets.fromLTRB(
                      //                                     8, 2, 8, 2),
                      //                             child: Center(
                      //                               child: Text(
                      //                                 "ADD",
                      //                                 textAlign: TextAlign.center,
                      //                                 style: TextStyle(
                      //                                     fontSize: 12,
                      //                                     color: Colors.teal[900]),
                      //                               ),
                      //                             ),
                      //                           ),
                      //                           Padding(
                      //                             padding:
                      //                                 const EdgeInsets.all(5.0),
                      //                             child: Icon(
                      //                               Icons.add,
                      //                               color: Colors.teal[900],
                      //                               size: 10,
                      //                             ),
                      //                           )
                      //                         ],
                      //                       ),
                      //                     ),
                      //             ),
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ).toList(),
                      // ),
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
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
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
      isLoading = false;
    });
  }

  TextEditingController productName = TextEditingController();
  TextEditingController brandName = TextEditingController();
  TextEditingController productQty = TextEditingController();
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.teal[50],
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Suggested Product Name",
                        hintStyle: TextStyle(
                            color: Colors.teal[200],
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
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(10),
                              filled: true,
                              fillColor: Colors.teal[50],
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue),
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "QTY",
                              hintStyle: TextStyle(
                                  color: Colors.teal[200],
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(10),
                              filled: true,
                              fillColor: Colors.teal[50],
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue),
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Brand Name",
                              hintStyle: TextStyle(
                                  color: Colors.teal[200],
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
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.teal[700])),
                          onPressed: () {
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
                                    content: Text("Product Suggestion Failed"),
                                  ),
                                );
                              }
                            });
                          },
                          child: Text(
                            "Send",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white),
                          ))),
                ]))));
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
