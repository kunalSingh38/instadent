// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously, unused_local_variable, prefer_is_empty

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/google_map.dart';
import 'package:instadent/home.dart';
import 'package:instadent/main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'apis/category_api.dart';
import 'apis/other_api.dart';

class AddressListScreen extends StatefulWidget {
  Map m = {};
  AddressListScreen({required this.m});

  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String phoneNumber = "";
  int groupValue = 0;
  List addressList = [];
  List recentSearch = [];
  String currentPincode = "";
  Future<void> getAddressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      LoginAPI().addressList().then((value) {
        setState(() {
          addressList.clear();
          // value.sort((a, b) => a['id'].compareTo(b['id']));
          addressList.addAll(value);
          isLoading = false;
        });
      });
    } else {
      isLoading = false;
    }

    if (pref.containsKey("recent_address_list")) {
      print(pref.getString("recent_address_list"));
      List list = jsonDecode(pref.getString("recent_address_list").toString());

      setState(() {
        recentSearch.addAll(list.toSet().toList());
      });
    }
  }

  getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    currentPincode = pref.getString("pincode").toString();
    setState(() {
      phoneNumber = pref.getString("userPhoneNo").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.m.isNotEmpty) {
      recentSearch.add({
        "address_type": widget.m['address_type'].toString(),
        "address": widget.m['address'].toString(),
        "pincode": widget.m['pincode'].toString(),
      });
    }
    getAddressList();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          // actions: [
          //   phoneNumber == "null"
          //       ? SizedBox()
          //       : TextButton.icon(
          //           onPressed: () {
          //             Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => AddUpdateAddressScreen(
          //                           update: false,
          //                           map: {},
          //                         ))).then((value) {
          //               getAddressList();
          //             });
          //           },
          //           icon: Icon(Icons.add),
          //           label: Text("ADD"))
          // ],
          leading: backIcon(context),
          elevation: 3,
          title: const Text(
            "Address List",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
          ),
        ),
        body: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return phoneNumber == "null"
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Text("Log in or sign up to view your complete profile",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500, fontSize: 15)),
                      SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                          width: MediaQuery.of(context).size.width / 1.25,
                          height: 45,
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          side: BorderSide(
                                              color: Color(0xFF1B5E20)))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white)),
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  DashboardState.currentTab = 0;
                                });

                                await prefs.clear().then((value) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SplashScreen()),
                                          (route) => false);
                                });
                              },
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.green[900],
                                    fontSize: 16),
                              ))),
                      Divider(
                        height: 20,
                        thickness: 0.9,
                        color: Colors.grey[300],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          onTap: () {
                            // setState(() {
                            //   isLoading = true;
                            // });
                            _determinePosition().then((value) async {
                              // setState(() {
                              //   isLoading = false;
                              // });
                              await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GoogleMapForAddress(
                                            lat: value.latitude.toString(),
                                            long: value.longitude.toString(),
                                          )));
                              // _getAddress(value);
                            });
                          },
                          dense: true,
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Image.asset(
                              "assets/gps.png",
                              color: Colors.brown[400],
                              scale: 18,
                            ),
                          ),
                          title: Text(
                            "Current Location",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.brown[400]),
                          ),
                          subtitle: Text(
                            "Using GPS",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.brown[400]),
                          ),
                        ),
                      ),
                      // Divider(
                      //   thickness: 8,
                      //   color: Colors.grey[300],
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: 55, top: 20, bottom: 20, right: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "RECENT SEARCHES",
                      //         style: TextStyle(
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.grey),
                      //       ),
                      //       InkWell(
                      //         onTap: () async {
                      //           SharedPreferences pref =
                      //               await SharedPreferences.getInstance();
                      //           pref.remove("recent_address_list");
                      //           setState(() {
                      //             recentSearch.clear();
                      //           });
                      //         },
                      //         child: Text(
                      //           "CLEAR",
                      //           style: TextStyle(
                      //               fontSize: 12,
                      //               fontWeight: FontWeight.w500,
                      //               color: Colors.grey[700]),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // recentSearch.length == 0
                      //     ? SizedBox()
                      //     : Column(
                      //         children: recentSearch
                      //             .toSet()
                      //             .toList()
                      //             .map(
                      //               (e) => InkWell(
                      //                 onTap: () async {
                      //                   setDefaultAddress(
                      //                       e['pincode'].toString(),
                      //                       e['address'].toString(),
                      //                       e['address_type'].toString(),
                      //                       viewModel.counter.toString());
                      //                 },
                      //                 child: Padding(
                      //                     padding:
                      //                         const EdgeInsets.only(bottom: 10),
                      //                     child: Row(
                      //                       children: [
                      //                         Expanded(
                      //                             child: currentPincode ==
                      //                                     e['pincode']
                      //                                         .toString()
                      //                                 ? Image.asset(
                      //                                     "assets/placeholder_1.png",
                      //                                     scale: 20,
                      //                                   )
                      //                                 : Image.asset(
                      //                                     "assets/placeholder.png",
                      //                                     scale: 20,
                      //                                   )),
                      //                         Expanded(
                      //                             flex: 6,
                      //                             child: Column(
                      //                               crossAxisAlignment:
                      //                                   CrossAxisAlignment
                      //                                       .start,
                      //                               children: [
                      //                                 Text(
                      //                                   e['address_type']
                      //                                       .toString(),
                      //                                   style: TextStyle(
                      //                                       fontSize: 14,
                      //                                       fontWeight:
                      //                                           FontWeight
                      //                                               .w600),
                      //                                 ),
                      //                                 SizedBox(
                      //                                   width: 5,
                      //                                 ),
                      //                                 Text(
                      //                                   capitalize(e['address']
                      //                                       .toString()),
                      //                                   maxLines: 2,
                      //                                   overflow: TextOverflow
                      //                                       .ellipsis,
                      //                                 ),
                      //                                 recentSearch.indexOf(e) ==
                      //                                         recentSearch
                      //                                                 .length -
                      //                                             1
                      //                                     ? SizedBox()
                      //                                     : Divider(
                      //                                         thickness: 0.9,
                      //                                         height: 40,
                      //                                       ),
                      //                               ],
                      //                             )),
                      //                       ],
                      //                     )),
                      //               ),
                      //             )
                      //             .toList(),
                      //       ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: ListTile(
                          onTap: () {
                            // print("object");
                            // setState(() {
                            //   isLoading = true;
                            // });
                            _determinePosition().then((value) async {
                              // setState(() {
                              //   isLoading = false;
                              // });
                              if (value.toString().isNotEmpty) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            GoogleMapForAddress(
                                              lat: value.latitude.toString(),
                                              long: value.longitude.toString(),
                                            )));
                              }
                            });
                          },
                          dense: true,
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Image.asset(
                              "assets/gps.png",
                              color: Colors.brown[400],
                              scale: 18,
                            ),
                          ),
                          title: Text(
                            "Current Location",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.brown[400]),
                          ),
                          subtitle: Text(
                            "Using GPS",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.brown[400]),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 8,
                        color: Colors.grey[300],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 55, top: 20, bottom: 20, right: 10),
                        child: Text(
                          "SAVED ADDRESSES",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey),
                        ),
                      ),
                      Column(
                        children: addressList
                            .map(
                              (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      LoginAPI()
                                          .setDefaultAddressAPI(
                                              e['id'].toString())
                                          .then((value) {
                                        if (value) {
                                          setDefaultAddress(
                                              e['pincode'].toString(),
                                              e['address'].toString(),
                                              e['address_type'].toString(),
                                              viewModel.counter.toString());
                                        }
                                      });
                                      setState(() {
                                        prefs.setString(
                                            'pincode', e['pincode']);
                                      });
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: e['is_default'] == 1
                                                ? Image.asset(
                                                    "assets/placeholder_1.png",
                                                    scale: 20,
                                                  )
                                                : Image.asset(
                                                    "assets/placeholder.png",
                                                    scale: 20,
                                                  )),
                                        Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e['address_type']
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  capitalize(e['address']
                                                          .toString()
                                                          .replaceAll(",", "") +
                                                      ", " +
                                                      e['pincode'].toString()),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                addressList.indexOf(e) ==
                                                        addressList.length - 1
                                                    ? SizedBox()
                                                    : Divider(
                                                        thickness: 0.9,
                                                        height: 40,
                                                      ),
                                              ],
                                            )),
                                        Expanded(
                                            child: PopupMenuButton(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(
                                                  Icons.more_vert_rounded,
                                                  color: Colors.grey[600],
                                                ),
                                                onSelected: (item) {
                                                  switch (item) {
                                                    case "EDIT":
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddUpdateAddressScreen(
                                                                    update:
                                                                        true,
                                                                    map: e,
                                                                  ))).then(
                                                          (value) {
                                                        getAddressList();
                                                      });
                                                      break;
                                                    case "REMOVE":
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          action:
                                                              SnackBarAction(
                                                                  label:
                                                                      "Remove",
                                                                  onPressed:
                                                                      () {
                                                                    addressList.length ==
                                                                            1
                                                                        ? ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                            SnackBar(
                                                                              duration: Duration(seconds: 1),
                                                                              content: Text("Cannot Remove default address."),
                                                                            ),
                                                                          )
                                                                        : LoginAPI()
                                                                            .removeAddress(e['id'].toString())
                                                                            .then((value) {
                                                                            if (value) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                SnackBar(
                                                                                  duration: Duration(seconds: 1),
                                                                                  content: Text("Address Removed."),
                                                                                ),
                                                                              );
                                                                              getAddressList();
                                                                            }
                                                                          });
                                                                  }),
                                                          content: Text(
                                                              "Want to remove?"),
                                                        ),
                                                      );
                                                      break;
                                                  }
                                                },
                                                itemBuilder:
                                                    (BuildContext context) => [
                                                          "EDIT",
                                                          "REMOVE"
                                                        ]
                                                            .map((e) =>
                                                                PopupMenuItem(
                                                                  value: e,
                                                                  child: Text(
                                                                    e,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ))
                                                            .toList()))
                                      ],
                                    ),
                                  )),
                            )
                            .toList(),
                      ),
                      // Divider(
                      //   color: Colors.black,
                      //   thickness: 1,
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       left: 55, top: 20, bottom: 20, right: 20),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         "RECENT SEARCHES",
                      //         style: TextStyle(
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.grey),
                      //       ),
                      //       InkWell(
                      //         onTap: () async {
                      //           SharedPreferences pref =
                      //               await SharedPreferences.getInstance();
                      //           pref.remove("recent_address_list");
                      //           setState(() {
                      //             recentSearch.clear();
                      //           });
                      //         },
                      //         child: Text(
                      //           "CLEAR",
                      //           style: TextStyle(
                      //               fontSize: 12,
                      //               fontWeight: FontWeight.w500,
                      //               color: Colors.grey[700]),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Column(
                      //   children: recentSearch.toSet().toList().map((e) {
                      //     bool showAddAddressToSavedAddress = addressList
                      //                 .where((element) =>
                      //                     element['pincode'].toString() ==
                      //                     e['pincode'].toString())
                      //                 .toList()
                      //                 .length !=
                      //             0
                      //         ? true
                      //         : false;

                      //     return InkWell(
                      //       onTap: () async {
                      //         setDefaultAddress(
                      //             e['pincode'].toString(),
                      //             e['address'].toString(),
                      //             e['address_type'].toString(),
                      //             viewModel.counter.toString());
                      //       },
                      //       child: Padding(
                      //           padding: const EdgeInsets.only(bottom: 10),
                      //           child: Row(
                      //             children: [
                      //               Expanded(
                      //                   child:
                      //                       //  currentPincode ==
                      //                       //         e['pincode'].toString()
                      //                       //     ? Image.asset(
                      //                       //         "assets/placeholder_1.png",
                      //                       //         scale: 20,
                      //                       //       )
                      //                       //     :
                      //                       Image.asset(
                      //                 "assets/placeholder.png",
                      //                 scale: 20,
                      //               )),
                      //               Expanded(
                      //                   flex: 6,
                      //                   child: Column(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment.start,
                      //                     children: [
                      //                       Text(
                      //                         e['address_type'].toString(),
                      //                         style: TextStyle(
                      //                             fontSize: 14,
                      //                             fontWeight: FontWeight.w600),
                      //                       ),
                      //                       SizedBox(
                      //                         width: 5,
                      //                       ),
                      //                       Text(
                      //                         capitalize(e['address']
                      //                             .toString()
                      //                             .replaceAll(",", "")),
                      //                         maxLines: 2,
                      //                         overflow: TextOverflow.ellipsis,
                      //                       ),
                      //                       Align(
                      //                         alignment: Alignment.centerRight,
                      //                         child:
                      //                             !showAddAddressToSavedAddress
                      //                                 ? Padding(
                      //                                     padding:
                      //                                         const EdgeInsets
                      //                                                 .only(
                      //                                             right: 20),
                      //                                     child: ElevatedButton(
                      //                                         style:
                      //                                             ButtonStyle(
                      //                                                 shape: MaterialStateProperty.all<
                      //                                                         RoundedRectangleBorder>(
                      //                                                     RoundedRectangleBorder(
                      //                                                   borderRadius:
                      //                                                       BorderRadius.circular(18.0),
                      //                                                 )),
                      //                                                 backgroundColor:
                      //                                                     MaterialStateProperty.all(Colors.blue[
                      //                                                         900])),
                      //                                         onPressed:
                      //                                             () async {
                      //                                           Navigator.push(
                      //                                               context,
                      //                                               MaterialPageRoute(
                      //                                                   builder: (context) =>
                      //                                                       AddUpdateAddressScreen(
                      //                                                         update: false,
                      //                                                         map: e,
                      //                                                       ))).then(
                      //                                               (value) {
                      //                                             getAddressList();
                      //                                           });
                      //                                           // LoginAPI()
                      //                                           //     .addAddress(m);
                      //                                         },
                      //                                         child: Text(
                      //                                             "Add to saved addresses")),
                      //                                   )
                      //                                 : SizedBox(),
                      //                       ),
                      //                       recentSearch.indexOf(e) ==
                      //                               recentSearch.length - 1
                      //                           ? SizedBox()
                      //                           : Divider(
                      //                               thickness: 0.9,
                      //                               height: 40,
                      //                             ),
                      //                     ],
                      //                   )),
                      //             ],
                      //           )),
                      //     );
                      //   }).toList(),
                      // ),
                    ],
                  ),
                );
        }),
      ),
    );
  }

  double currentIndexPage = 0;
  List bannerImagesList = [];
  String announcment = "";
  List categoryList = [];
  bool isLoadingAllCategory = false;

  List recentOrderItems = [];
  void setDefaultAddress(
      String pincode, String address, String address_type, String count) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (int.parse(count.toString()) > 0) {
      if (pref.getString("pincode").toString() != pincode) {
        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                  title: Text("Remove cart items?"),
                  content: Text(
                    "Your cart contains items from " +
                        pref.getString("address_type").toString() +
                        " (" +
                        pref.getString("defaultAddress").toString() +
                        "). Do you want to discard the selection and use this address " +
                        address_type +
                        " (" +
                        address +
                        ")?",
                    style: TextStyle(
                      fontSize: 14,
                      wordSpacing: 1,
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: Text(
                          "NO",
                          style: TextStyle(color: Colors.amber[700]),
                        )),
                    TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();

                          pref.setString("pincode", pincode.toString());
                          pref.setString("defaultAddress", address);
                          pref.setString("address_type", address_type);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(address_type.toString() +
                                    " set as default address."),
                                duration: Duration(seconds: 1)),
                          );
                          Provider.of<UpdateCartData>(context, listen: false)
                              .setDefaultAddress();
                          setState(() {
                            currentPincode = pincode.toString();
                          });
                          CartAPI().emptyCart().then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("All items removed from cart."
                                        .toString()),
                                    duration: Duration(seconds: 1)),
                              );

                              Provider.of<UpdateCartData>(context,
                                      listen: false)
                                  .incrementCounter();
                              Provider.of<UpdateCartData>(context,
                                      listen: false)
                                  .showCartorNot();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Cart removal failed".toString()),
                                    duration: Duration(seconds: 1)),
                              );
                            }
                          });
                        },
                        child: Text("YES",
                            style: TextStyle(color: Colors.amber[700])))
                  ],
                ));
      } else {
        print("test----------");
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text("You have selected same address"),
        //       duration: Duration(seconds: 1)),
        // );
        Navigator.of(context).pop();
        print(pincode);
        print(address);
        print(address_type);
        setState(() {
          pref.setString("pincode", pincode.toString());
          pref.setString("defaultAddress", address);
          pref.setString("address_type", address_type);
        });

        Provider.of<UpdateCartData>(context, listen: false)
            .setDefaultAddress()
            .then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .checkForServiceable();
          Provider.of<UpdateCartData>(context, listen: false)
              .setDeliveryAddress(
                  address_type + ", " + address + ", " + pincode);
        });
      }
    } else {
      // Navigator.pop(context, true);
      // reloadApis();
      print("test2----------");
      setState(() {
        pref.setString("pincode", pincode.toString());
        pref.setString("defaultAddress", address);
        pref.setString("address_type", address_type);
      });

      print(pref.getString("token"));

      // log("Default Pin Code---->" + pref.getString('pincode').toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(address_type.toString() + " set as default address."),
            duration: Duration(seconds: 1)),
      );
      Provider.of<UpdateCartData>(context, listen: false)
          .setDefaultAddress()
          .then((value) {
        Provider.of<UpdateCartData>(context, listen: false)
            .checkForServiceable();
        Provider.of<UpdateCartData>(context, listen: false)
            .setDeliveryAddress(address_type + ", " + address + ", " + pincode);
      });

      setState(() {
        currentPincode = pincode.toString();
      });
      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => HomeScreen())));
    }
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

      recentSearch.add({
        "address_type": place.subLocality.toString(),
        "address": defaultAddress,
        "pincode": place.postalCode.toString()
      });
      pref.setString(
          "recent_address_list", jsonEncode(recentSearch.toSet().toList()));
      currentPincode = place.postalCode.toString();
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  String defaultAddress = "";
  bool isLoading = true;

  // TextEditingController addTypeNew = TextEditingController();
  // TextEditingController addressNew = TextEditingController();
  // TextEditingController addPincodeNew = TextEditingController();
  // TextEditingController addLandmarkNew = TextEditingController();
  // GlobalKey<FormState> addAddressKey = GlobalKey();
  // Future<void> suggestProductBottom(Map e) async {
  //   setState(() {
  //     addTypeNew.text = e['address_type'].toString();
  //     addressNew.text = e['address'].toString();
  //     addPincodeNew.text = e['pincode'].toString();
  //   });
  //   await showModalBottomSheet(
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
  //       backgroundColor: Colors.white,
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (context) => Padding(
  //           padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
  //           child: SingleChildScrollView(
  //               child: Form(
  //             key: addAddressKey,
  //             child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text("Add to saved address",
  //                       style: GoogleFonts.montserrat(
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                           color: Colors.grey)),
  //                   Divider(
  //                     thickness: 0.9,
  //                     color: Colors.grey,
  //                     height: 20,
  //                   ),
  //                   TextFormField(
  //                     controller: addTypeNew,
  //                     style:
  //                         TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  //                     maxLines: 1,
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'Required Field';
  //                       }
  //                       return null;
  //                     },
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10)),
  //                       contentPadding: EdgeInsets.all(10),
  //                       // filled: true,
  //                       // fillColor: Colors.teal[50],
  //                       focusedBorder: OutlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.lightBlue),
  //                           borderRadius: BorderRadius.circular(10)),
  //                       hintText: "Address Type",
  //                       hintStyle: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w400),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 8,
  //                   ),
  //                   TextFormField(
  //                     controller: addressNew,
  //                     style:
  //                         TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //                     maxLines: 3,
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'Required Field';
  //                       }
  //                       return null;
  //                     },
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10)),
  //                       contentPadding: EdgeInsets.all(10),
  //                       // filled: true,
  //                       // fillColor: Colors.teal[50],
  //                       focusedBorder: OutlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.lightBlue),
  //                           borderRadius: BorderRadius.circular(10)),
  //                       hintText: "Complete Address",
  //                       hintStyle: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w400),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 8,
  //                   ),
  //                   TextFormField(
  //                     controller: addLandmarkNew,
  //                     style:
  //                         TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //                     maxLines: 1,
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'Required Field';
  //                       }
  //                       return null;
  //                     },
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10)),
  //                       contentPadding: EdgeInsets.all(10),
  //                       // filled: true,
  //                       // fillColor: Colors.teal[50],
  //                       focusedBorder: OutlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.lightBlue),
  //                           borderRadius: BorderRadius.circular(10)),
  //                       hintText: "Landmark",
  //                       hintStyle: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w400),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 8,
  //                   ),
  //                   TextFormField(
  //                     controller: addPincodeNew,
  //                     style:
  //                         TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //                     maxLines: 1,
  //                     validator: (value) {
  //                       if (value == null || value.isEmpty) {
  //                         return 'Required Field';
  //                       }
  //                       return null;
  //                     },
  //                     decoration: InputDecoration(
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(10)),
  //                       contentPadding: EdgeInsets.all(10),
  //                       // filled: true,
  //                       // fillColor: Colors.teal[50],
  //                       focusedBorder: OutlineInputBorder(
  //                           borderSide: BorderSide(color: Colors.lightBlue),
  //                           borderRadius: BorderRadius.circular(10)),
  //                       hintText: "Pincode",
  //                       hintStyle: TextStyle(
  //                           color: Colors.grey,
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.w400),
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 8,
  //                   ),
  //                   SizedBox(
  //                       width: MediaQuery.of(context).size.width / 1.15,
  //                       height: 45,
  //                       child: ElevatedButton(
  //                           style: ButtonStyle(
  //                               shape: MaterialStateProperty.all(
  //                                   RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(10.0),
  //                               )),
  //                               backgroundColor: MaterialStateProperty.all(
  //                                   Colors.teal[700])),
  //                           onPressed: () {
  //                             if (suggestForm.currentState!.validate()) {
  //                               Navigator.of(context).pop();
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content: Text("Adding suggested product"),
  //                                 ),
  //                               );
  //                               OtherAPI()
  //                                   .requestProduct(
  //                                       productName.text.toString(),
  //                                       brandName.text.toString(),
  //                                       productQty.text.toString())
  //                                   .then((value) {
  //                                 if (value) {
  //                                   suggestProductBottomThankYou();
  //                                 } else {
  //                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                     SnackBar(
  //                                       content:
  //                                           Text("Product Suggestion Failed"),
  //                                     ),
  //                                   );
  //                                 }
  //                               });
  //                             } else {
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 SnackBar(
  //                                   content:
  //                                       Text("Please enter required fields"),
  //                                   duration: Duration(milliseconds: 500),
  //                                 ),
  //                               );
  //                             }
  //                           },
  //                           child: Text(
  //                             "Save",
  //                             style: TextStyle(
  //                                 fontWeight: FontWeight.w400,
  //                                 fontSize: 16,
  //                                 color: Colors.white),
  //                           ))),
  //                 ]),
  //           ))));
  // }
  String getItemResponse = '';
  int dataAccess = 0;
  Future getAccessDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String currentPincode = pref.getString("pincode").toString();
    var url = "https://admin.instadent.in/api/v1/pincode-estimate-delivery";
    var body = {
      "pincode": currentPincode,
    };
    var response = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );

    var result = jsonDecode(response.body);
    dataAccess = result['ErrorCode'];

    if (dataAccess == 0) {
      pref.setInt("getAscess", dataAccess);
      getItemResponse =
          result['ItemResponse']['delivery_expected_time'].toString();

      log("item response--->$getItemResponse");
      var snackBar = SnackBar(
        content: Text(result['ErrorMessage']),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      var snackBar = SnackBar(
        content: Text(result['ErrorMessage']),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List carouselsList = [];
  bool isLoadingCarosole = true;

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
}
