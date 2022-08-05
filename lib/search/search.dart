// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_is_empty

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
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
              });
              print(searchResult[0]);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("No result found".toString()),
                    duration: Duration(seconds: 1)),
              );
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
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("No result found".toString()),
                    duration: Duration(seconds: 1)),
              );
            }
          });
        }
      }
    } else {
      setState(() {
        searchResult.clear();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recentSearchItems();
    myFocusNode = FocusNode();
    CategoryAPI().featuredProducts().then((value) {
      if (value.length > 0) {
        setState(() {
          featureProducts.clear();
          featureProducts.addAll(value);
        });
      }
    });
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

  Future<bool> _onWillPop() async {
    // This dialog will exit your app on saying yes

    Provider.of<UpdateCartData>(context, listen: false).changeSearchView();
    Provider.of<UpdateCartData>(context, listen: false).changeSearchView();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateCartData>(builder: (context, viewModel, child) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // bottomNavigationBar: viewModel.counterShowCart ? bottomSheet() : null,
          // appBar: AppBar(
          //   backgroundColor: Colors.transparent,
          //   elevation: 0,
          //   iconTheme: IconThemeData(color: Colors.black),
          //   toolbarHeight: 50,
          // ),
          appBar: AppBar(
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.all(10),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlue),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: searchHint,
                      hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                      prefixIcon: InkWell(
                          onTap: () {
                            Provider.of<UpdateCartData>(context, listen: false)
                                .changeSearchView();
                          },
                          child: Icon(Icons.arrow_back)),
                      suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              searchCont.clear();
                              searchResult.clear();
                              myFocusNode.requestFocus();
                            });
                          },
                          child: Image.asset(
                            "assets/clear.png",
                            scale: 30,
                          ))),
                ),
              )),
          body: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          children: [
                            items.length == 0
                                ? SizedBox()
                                : Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onTap: () async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              setState(() {
                                                items.clear();
                                                prefs.remove("recentSearch");
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
                                              width: MediaQuery.of(context)
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
                                                        searchCont.clear();
                                                        searchCont.text =
                                                            items[index]
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
                                                                  .all(8.0),
                                                          child: Text(
                                                            items[index]
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey[700]),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
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
                                                onTap: () {},
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 0.9),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Colors
                                                                  .tealAccent[50],
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  Image.network(
                                                                e['product_image']
                                                                    .toString(),
                                                                fit: BoxFit
                                                                    .cover,
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
                                                            ))),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      e['product_name'] == ""
                                                          ? "No Name"
                                                          : e['product_name']
                                                              .toString(),
                                                      softWrap: true,
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12),
                                                    ))
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  )
                                : allProductsList(
                                    searchResult, context, controller, 0.8);
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
                  child: viewModel.counterShowCart ? bottomSheet() : SizedBox())
            ],
          ),
        ),
      );
    });
  }

  TextEditingController controller = TextEditingController();
}
