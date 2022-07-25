// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_interpolation_to_compose_strings, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/main.dart';
import 'package:instadent/search/search.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSearchVisible = false;
  TextEditingController searchCont = TextEditingController();

  TextStyle textStyle1 = TextStyle(color: Colors.white);
  GlobalKey key = GlobalKey();
  String defaultAddress = "Select Address";
  List addressList = [];
  bool isLoading = true;
  Future<void> getAddressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      LoginAPI().addressList().then((value) {
        setState(() {
          addressList.clear();
          addressList.addAll(value);
          isLoading = false;
        });

        addressList.forEach((element) {
          if (element['is_default'] == 1) {
            setState(() {
              defaultAddress = element['address'].toString() +
                  ", " +
                  element['pincode'].toString();
              pref.setString("pincode", element['pincode'].toString());
            });
          }
        });
      });
    } else {
      _determinePosition().then((value) {
        _getAddress(value);
      });
    }
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
                    MaterialPageRoute(builder: (context) => SearchScreen()))
                .then((value) {
              setState(() {
                isSearchVisible = false;
              });
            });
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getAddressList();
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
            appBar: isSearchVisible
                ? AppBar(
                    backgroundColor: Colors.white,
                    toolbarHeight: 60,
                    title: searchCard())
                : null,
            bottomSheet: bottomSheet(),
            body: SingleChildScrollView(
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
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddressListScreen()))
                                  .then((value) => getAddressList());
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 15,
                                  child: Text(defaultAddress.toString(),
                                      overflow: TextOverflow.ellipsis,
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
                        VisibilityDetector(
                            key: key,
                            onVisibilityChanged: (info) {
                              var visiblePercentage =
                                  info.visibleFraction * 100;
                              var visible =
                                  visiblePercentage.toStringAsFixed(0);
                              print(visible);
                              if (int.parse(visible) < 20) {
                                setState(() {
                                  isSearchVisible = true;
                                });
                              } else {
                                setState(() {
                                  isSearchVisible = false;
                                });
                              }
                            },
                            child: searchCard()),
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
                                5,
                                (index) => Image.asset(
                                      'assets/logo.png',
                                    )).toList(),
                            onPageChanged: (value) {},
                            autoPlayInterval: 2000,
                            isLoop: true,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.55,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: List.generate(
                              18,
                              (index) => InkWell(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        Expanded(
                                            flex: 2,
                                            child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.teal[100],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.asset(
                                                    "assets/logo.png",
                                                    // fit: BoxFit.fill,
                                                  ),
                                                ))),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                            child: Text(
                                          "Demo Category Name",
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ))
                                      ],
                                    ),
                                  )).toList(),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 10,
                    color: Colors.grey[200],
                  ),
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
                ],
              ),
            ),
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
      defaultAddress = place.subAdministrativeArea.toString() +
          " ," +
          place.name.toString() +
          " ," +
          place.subLocality.toString() +
          " ," +
          place.locality.toString() +
          " ," +
          place.postalCode.toString() +
          " ," +
          place.country.toString();
      //   latitudeGet = value.latitude;
      //   longitudeGet = value.longitude;

      isLoading = false;
    });
  }
}
