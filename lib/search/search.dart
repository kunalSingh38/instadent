// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_is_empty

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  late FocusNode myFocusNode;
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  List items = [];

  List searchResult = [];
  List featureProducts = [];
  late StreamSubscription<bool> keyboardSubscription;

  TextEditingController searchCont = TextEditingController();
  recentSearchItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("recentSearch").toString() != "null") {
      List temp = prefs.getString("recentSearch").toString().split(",");

      setState(() {
        items.clear();

        items.addAll(temp.toSet().toList());
      });
    }
  }

  void searching() async {
    if (searchCont.text.length > 2) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (searchCont.text.isNotEmpty) {
        setState(() {
          isLoading = true;
          searchFound = "";
        });

        if (prefs.getBool("loggedIn") ?? false) {
          CategoryAPI()
              .searchProducts(searchCont.text.toString())
              .then((value) {
            setState(() {
              isLoading = false;
            });
            if (value.length > 0) {
              setState(() {
                searchResult.clear();
                searchResult.addAll(value);
                searchFound = "yes";
              });
              print(searchResult[0]);
            } else {
              setState(() {
                searchFound = "no";
              });
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //       content: Text("No result found".toString()),
              //       duration: Duration(seconds: 1)),
              // );
            }
          });
        } else {
          CategoryAPI()
              .searchProductsWithoutLogin(searchCont.text.toString())
              .then((value) {
            setState(() {
              isLoading = false;
            });
            if (value.length > 0) {
              setState(() {
                searchResult.clear();
                searchResult.addAll(value);
                searchFound = "yes";
              });
            } else {
              setState(() {
                searchFound = "no";
              });
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //       content: Text("No result found".toString()),
              //       duration: Duration(seconds: 1)),
              // );
            }
          });
        }
      }
    } else {
      setState(() {
        searchResult.clear();
        searchFound = "";
      });
    }
  }

  void addRecentItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (searchCont.text.toString().length != 0) {
      items.add(searchCont.text);
      prefs.setString("recentSearch", items.toSet().toList().join(","));
    }
  }

  getFeaturedList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      print("with feature");
      CategoryAPI().featuredProductsWithLogin().then((value) {
        if (value.length > 0) {
          setState(() {
            featureProducts.clear();
            featureProducts.addAll(value);
          });
        }
      });
    } else {
      CategoryAPI().featuredProductsWithoutLogin().then((value) {
        print("without feature");
        if (value.length > 0) {
          setState(() {
            featureProducts.clear();
            featureProducts.addAll(value);
          });
        }
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

  late stt.SpeechToText _speech;
  String searchFound = "";
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;
  String listing = "";
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          setState(() {
            listing = val;
          });
        },
        onError: (val) {},
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
              if (_text.isNotEmpty) {
                setState(() {
                  _isListening = false;
                  searchCont.text = _text;
                  searching();
                  FocusScope.of(context).unfocus();
                });
              }
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText();
    recentSearchItems();
    myFocusNode = FocusNode();

    getFeaturedList();
    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!visible) {
        addRecentItems();
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(searchFound);
    return Consumer<UpdateCartData>(builder: (context, viewModel, child) {
      return Scaffold(
        // bottomNavigationBar: viewModel.counterShowCart ? bottomSheet() : null,
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        //   iconTheme: IconThemeData(color: Colors.black),
        //   toolbarHeight: 50,
        // ),

        appBar: !viewModel.counterServicable
            ? AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                toolbarHeight: 80,
              )
            : AppBar(
                bottom: _isListening
                    ? PreferredSize(
                        preferredSize: Size(double.infinity, 1.0),
                        child: LinearProgressIndicator(),
                      )
                    : null,
                elevation: 0,
                backgroundColor: Colors.transparent,
                toolbarHeight: 80,
                title: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFFEEEEEE))),
                  child: TextFormField(
                    focusNode: myFocusNode,
                    // autofocus: true,
                    controller: searchCont,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    onChanged: (val) async {
                      searching();
                    },
                    onEditingComplete: () {
                      // addRecentItems();
                      searching();
                      FocusScope.of(context).unfocus();
                    },
                    decoration: InputDecoration(
                        // isCollapsed: true,
                        isDense: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(5),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: searchHint,
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w300),
                        prefixIcon: InkWell(
                          onTap: () {
                            _listen();
                          },
                          child: Image.asset(
                            "assets/mic.png",
                            scale: 25,
                          ),
                        ),
                        suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                searchCont.clear();
                                searchResult.clear();
                                myFocusNode.requestFocus();
                                _isListening = false;
                              });
                            },
                            child: Image.asset(
                              "assets/clear.png",
                              scale: 35,
                            ))),
                  ),
                )),
        body: !viewModel.counterServicable
            ? Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Image.asset(
                  "assets/instadent service.jpg",
                  scale: 1,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  _speech = stt.SpeechToText();
                  recentSearchItems();
                  myFocusNode = FocusNode();
                  getFeaturedList();
                  var keyboardVisibilityController =
                      KeyboardVisibilityController();

                  keyboardSubscription = keyboardVisibilityController.onChange
                      .listen((bool visible) {
                    if (!visible) {
                      addRecentItems();
                    }
                  });
                  keyboardSubscription.cancel();
                },
                child: Stack(
                  children: [
                    SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            searchResult.length == 0
                                ? Column(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          suggestProductBottom();
                                        },
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.12,
                                          decoration: BoxDecoration(
                                              color: Colors.teal[100],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Center(
                                            child: Text(
                                              "Didn't find your product. Click to Suggest.",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  )
                                : SizedBox(),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: [
                                  items.length == 0
                                      ? SizedBox()
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.history),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      "Recent searches",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                                InkWell(
                                                  child: Text(
                                                    "Clear",
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onTap: () async {
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    setState(() {
                                                      items.clear();
                                                      prefs.remove(
                                                          "recentSearch");
                                                      searchResult.clear();
                                                      searchCont.text = "";
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            items.length == 0
                                                ? SizedBox()
                                                : SizedBox(
                                                    height: 35,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ListView.separated(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: items.length,
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                                  int index) =>
                                                              const SizedBox(
                                                        width: 10,
                                                      ),
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              searchCont
                                                                  .clear();
                                                              searchCont
                                                                  .text = items[
                                                                      index]
                                                                  .toString();
                                                              myFocusNode
                                                                  .requestFocus();
                                                            });
                                                          },
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10)),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Text(
                                                                  items[index]
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                              .grey[
                                                                          700]),
                                                                ),
                                                              )),
                                                        );
                                                      },
                                                    )),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                            searchResult.length == 0
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/feature.png",
                                          scale: 20,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Featured Products",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        )
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 20,
                            ),
                            Consumer<UpdateCartData>(
                                builder: (context, viewModel, child) {
                              return isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : searchResult.length == 0
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GridView.count(
                                            crossAxisCount: 4,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            childAspectRatio: 0.6,
                                            physics: ClampingScrollPhysics(),
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            children: featureProducts
                                                .map((e) => InkWell(
                                                      onTap: () {
                                                        print(e);
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        bool inStock =
                                                            e['is_stock'] == 1
                                                                ? false
                                                                : true;
                                                        showProdcutDetails(
                                                            context,
                                                            e,
                                                            inStock,
                                                            controller,
                                                            featureProducts,
                                                            dynamicLinks,
                                                            false);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                              flex: 2,
                                                              child: Container(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            0.9),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: Colors
                                                                        .tealAccent[50],
                                                                  ),
                                                                  child: ClipRRect(
                                                                      borderRadius: BorderRadius.circular(10),
                                                                      child: e['product_image'].toString() == "0"
                                                                          ? Image.asset(
                                                                              "assets/no_image.jpeg",
                                                                            )
                                                                          : cacheImage(e['product_image'].toString())))),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                            e['product_name'] ==
                                                                    ""
                                                                ? "No Name"
                                                                : e['product_name']
                                                                    .toString(),
                                                            softWrap: true,
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12),
                                                          ))
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        )
                                      : allProductsList(searchResult, context,
                                          controller, 0.7, dynamicLinks);
                            }),
                            viewModel.counterShowCart
                                ? SizedBox(
                                    height: 60,
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: viewModel.counterShowCart
                            ? bottomSheet()
                            : SizedBox()),
                  ],
                ),
              ),
      );
    });
  }

  TextEditingController controller = TextEditingController();
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
                          flex: 3,
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
