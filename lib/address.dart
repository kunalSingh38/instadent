// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';

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
import 'package:instadent/main.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

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

    if (pref.getString("recent_address_list").toString().isNotEmpty) {
      List list = jsonDecode(pref.getString("recent_address_list").toString());
      print(list.toString() + "__");
      setState(() {
        recentSearch.clear();
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
          actions: [
            phoneNumber == "null"
                ? SizedBox()
                : TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddUpdateAddressScreen(
                                    update: false,
                                    map: {},
                                  ))).then((value) {
                        getAddressList();
                      });
                    },
                    icon: Icon(Icons.add),
                    label: Text("ADD"))
          ],
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
                            setState(() {
                              isLoading = true;
                            });
                            _determinePosition().then((value) {
                              _getAddress(value);
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
                            left: 55, top: 20, bottom: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "RECENT SEARCHES",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey),
                            ),
                            InkWell(
                              onTap: () async {
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.remove("recent_address_list");
                                setState(() {
                                  recentSearch.clear();
                                });
                              },
                              child: Text(
                                "CLEAR",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: recentSearch
                            .toSet()
                            .toList()
                            .map(
                              (e) => InkWell(
                                onTap: () async {
                                  setDefaultAddress(
                                      e['pincode'].toString(),
                                      e['address'].toString(),
                                      e['address_type'].toString(),
                                      viewModel.counter.toString());
                                },
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: currentPincode ==
                                                    e['pincode'].toString()
                                                ? Image.asset(
                                                    "assets/placeholder_1.png",
                                                    scale: 20,
                                                  )
                                                : Image.asset(
                                                    "assets/placeholder.png",
                                                    scale: 20,
                                                  )),
                                        Expanded(
                                            flex: 6,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e['address_type'].toString(),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  capitalize(
                                                      e['address'].toString()),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                recentSearch.indexOf(e) ==
                                                        recentSearch.length - 1
                                                    ? SizedBox()
                                                    : Divider(
                                                        thickness: 0.9,
                                                        height: 40,
                                                      ),
                                              ],
                                            )),
                                      ],
                                    )),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });
                          _determinePosition().then((value) {
                            _getAddress(value);
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
                                    setDefaultAddress(
                                        e['pincode'].toString(),
                                        e['address'].toString(),
                                        e['address_type'].toString(),
                                        viewModel.counter.toString());
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: currentPincode ==
                                                  e['pincode'].toString()
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
                                                        .toString() +
                                                    ", " +
                                                    e['pincode'].toString()),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
                                                                  update: true,
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
                                                        action: SnackBarAction(
                                                            label: "Remove",
                                                            onPressed: () {
                                                              LoginAPI()
                                                                  .removeAddress(e[
                                                                          'id']
                                                                      .toString())
                                                                  .then(
                                                                      (value) {
                                                                if (value) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      duration: Duration(
                                                                          seconds:
                                                                              1),
                                                                      content: Text(
                                                                          "Address Removed."),
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
                                              itemBuilder: (BuildContext
                                                      context) =>
                                                  ["EDIT", "REMOVE"]
                                                      .map((e) => PopupMenuItem(
                                                            value: e,
                                                            child: Text(
                                                              e,
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ))
                                                      .toList()))
                                    ],
                                  ),
                                )),
                          )
                          .toList(),
                    ),
                    Divider(
                      color: Colors.black,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 55, top: 20, bottom: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "RECENT SEARCHES",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                          InkWell(
                            onTap: () async {
                              SharedPreferences pref =
                                  await SharedPreferences.getInstance();
                              pref.remove("recent_address_list");
                              setState(() {
                                recentSearch.clear();
                              });
                            },
                            child: Text(
                              "CLEAR",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: recentSearch
                          .toSet()
                          .toList()
                          .map(
                            (e) => InkWell(
                              onTap: () async {
                                setDefaultAddress(
                                    e['pincode'].toString(),
                                    e['address'].toString(),
                                    e['address_type'].toString(),
                                    viewModel.counter.toString());
                              },
                              child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: currentPincode ==
                                                  e['pincode'].toString()
                                              ? Image.asset(
                                                  "assets/placeholder_1.png",
                                                  scale: 20,
                                                )
                                              : Image.asset(
                                                  "assets/placeholder.png",
                                                  scale: 20,
                                                )),
                                      Expanded(
                                          flex: 6,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                e['address_type'].toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                capitalize(
                                                    e['address'].toString()),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              recentSearch.indexOf(e) ==
                                                      recentSearch.length - 1
                                                  ? SizedBox()
                                                  : Divider(
                                                      thickness: 0.9,
                                                      height: 40,
                                                    ),
                                            ],
                                          )),
                                    ],
                                  )),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
        }),
      ),
    );
  }

  void setDefaultAddress(
      String pincode, String address, String address_type, String count) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (int.parse(count.toString()) > 0) {
      print(pref.getString("pincode"));
      print(pincode);
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
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //       content: Text("You have selected same address"),
        //       duration: Duration(seconds: 1)),
        // );
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
      pref.setString("pincode", pincode.toString());
      pref.setString("defaultAddress", address);
      pref.setString("address_type", address_type);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(address_type.toString() + " set as default address."),
            duration: Duration(seconds: 1)),
      );
      Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
      setState(() {
        currentPincode = pincode.toString();
      });
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
}
