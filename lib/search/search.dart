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
        items.addAll(temp);
      });
    }
  }

  void searching(String value) async {
    if (value.length > 2) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (value.isNotEmpty) {
        setState(() {
          isLoading = true;
        });

        if (prefs.getBool("loggedIn") ?? false) {
          CategoryAPI().searchProducts(value.toString()).then((value) {
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
        } else {
          CategoryAPI()
              .searchProductsWithoutLogin(value.toString())
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
        keyboardVisibilityController.onChange.listen((bool visible) {});
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet(),
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   iconTheme: IconThemeData(color: Colors.black),
      //   toolbarHeight: 50,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Color(0xFFEEEEEE))),
                      child: TextFormField(
                        focusNode: myFocusNode,
                        controller: searchCont,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                        onChanged: (val) async {
                          searching(val);
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Search for atta, dal, coke and more",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                            prefixIcon: InkWell(
                                onTap: () {
                                  Provider.of<UpdateCartData>(context,
                                          listen: false)
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
                    ),
                    SizedBox(
                      height: 10,
                    ),
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
                                            fontWeight: FontWeight.bold),
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
                                          await SharedPreferences.getInstance();
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
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: items.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) =>
                                                const SizedBox(
                                          width: 10,
                                        ),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                searchCont.clear();
                                                searchCont.text =
                                                    items[index].toString();
                                                myFocusNode.requestFocus();
                                              });
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    items[index].toString(),
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[700]),
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
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                fontWeight: FontWeight.w700, fontSize: 14),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: 20,
              ),
              isLoading
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
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color:
                                                        Colors.tealAccent[50],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child: Image.network(
                                                      e['product_image']
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
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
                                                : e['product_name'].toString(),
                                            softWrap: true,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12),
                                          ))
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        )
                      : GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 0,
                          crossAxisSpacing: 0,
                          childAspectRatio: 0.56,
                          physics: ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: searchResult
                              .map(
                                (e) => AbsorbPointer(
                                  absorbing: false,
                                  child: Stack(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          await showProdcutDetails(context, e);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color(0xFFD6D6D6),
                                                  width: 0.3)),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    child: Image.asset(
                                                        "assets/logo.png")),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                  child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 15, 8, 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e['product_name']
                                                          .toString(),
                                                      textAlign: TextAlign.left,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 12),
                                                    ),
                                                    Text(
                                                      "500 g",
                                                      textAlign: TextAlign.left,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          fontSize: 12),
                                                    ),
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
                                                                            .toString()
                                                                            .split(".")[
                                                                        0],
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        12)),
                                                            Text(
                                                                "₹" +
                                                                    e['mrp'].toString().split(
                                                                        ".")[0],
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontSize:
                                                                        11,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                    color: Colors
                                                                        .grey))
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
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: Colors.teal,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              "25% OFF",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15, right: 10),
                                          child: Container(
                                            width: 75,
                                            height: 28,
                                            decoration: BoxDecoration(
                                                color: e['quantity'] > 0
                                                    ? Colors.teal[400]
                                                    : Colors.teal[50],
                                                border: Border.all(
                                                    color: Color(0xFF004D40)),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: e['quantity'] > 0
                                                ? Stack(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    8, 4, 2, 4),
                                                            child: Text(
                                                              "-",
                                                              style: textStyle1,
                                                            ),
                                                          ),
                                                          Text(
                                                            e['quantity']
                                                                .toString(),
                                                            style: textStyle1,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    2, 4, 8, 4),
                                                            child: Text(
                                                              "+",
                                                              style: textStyle1,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              await setQunatity(
                                                                  searchResult
                                                                      .indexOf(
                                                                          e),
                                                                  false);
                                                            },
                                                            child: Container(
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                          )),
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                controller
                                                                    .clear();
                                                              });
                                                              await manuallyUpdateQuantity(
                                                                  searchResult
                                                                      .indexOf(
                                                                          e));
                                                            },
                                                            child: Container(
                                                                color: Colors
                                                                    .transparent),
                                                          )),
                                                          Expanded(
                                                              child: InkWell(
                                                            onTap: () async {
                                                              await setQunatity(
                                                                  searchResult
                                                                      .indexOf(
                                                                          e),
                                                                  true);
                                                            },
                                                            child: Container(
                                                                color: Colors
                                                                    .transparent),
                                                          ))
                                                        ],
                                                      )
                                                    ],
                                                  )
                                                : InkWell(
                                                    onTap: () async {
                                                      await setQunatity(
                                                          searchResult
                                                              .indexOf(e),
                                                          true);
                                                    },
                                                    child: Stack(
                                                      alignment:
                                                          Alignment.topRight,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  8, 2, 8, 2),
                                                          child: Center(
                                                            child: Text(
                                                              "ADD",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                          .teal[
                                                                      900]),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors
                                                                .teal[900],
                                                            size: 10,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      e['is_stock'] == 1
                                          ? SizedBox()
                                          : Container(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              child: Center(
                                                child: Image.asset(
                                                  "assets/out-of-stock.png",
                                                  scale: 10,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Future setQunatity(int index, bool action) async {
    setState(() {
      isLoading = true;
    });
    if (action) {
      setState(() {
        searchResult[index]['quantity'] = searchResult[index]['quantity'] + 1;
        Map m = {
          "offer_price": searchResult[index]['discount_price'].toString(),
          "rate": int.parse(
              searchResult[index]['item_price'].toString().split(".")[0]),
          "quantity": searchResult[index]['quantity'].toString(),
          "product_id": searchResult[index]['id'].toString()
        };
        CartAPI().addToCart(m).then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .incrementCounter()
              .then((value) {
            Provider.of<UpdateCartData>(context, listen: false)
                .showCartorNot()
                .then((value) {
              setState(() {
                isLoading = false;
              });
            });
          });
        });
      });
    } else {
      setState(() {
        searchResult[index]['quantity'] = searchResult[index]['quantity'] - 1;
        Map m = {
          "offer_price": searchResult[index]['discount_price'].toString(),
          "rate": int.parse(
              searchResult[index]['item_price'].toString().split(".")[0]),
          "quantity": searchResult[index]['quantity'].toString(),
          "product_id": searchResult[index]['id'].toString()
        };
        print(m);
        CartAPI().addToCart(m).then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .incrementCounter()
              .then((value) {
            Provider.of<UpdateCartData>(context, listen: false)
                .showCartorNot()
                .then((value) {
              setState(() {
                isLoading = false;
              });
            });
          });
        });
      });
    }
  }

  TextEditingController controller = TextEditingController();
  Future<void> manuallyUpdateQuantity(int index) async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            height: 180,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Color(0xFFEEEEEE))),
                        child: TextFormField(
                          autofocus: true,
                          controller: controller,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Enter qunatity",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                        ),
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
                                      Colors.green[700])),
                              onPressed: () {
                                setState(() {
                                  searchResult[index]['quantity'] =
                                      int.parse(controller.text);

                                  Map m = {
                                    "offer_price": searchResult[index]
                                            ['discount_price']
                                        .toString(),
                                    "rate": int.parse(searchResult[index]
                                            ['item_price']
                                        .toString()
                                        .split(".")[0]),
                                    "quantity": searchResult[index]['quantity']
                                        .toString(),
                                    "product_id":
                                        searchResult[index]['id'].toString()
                                  };
                                  print(m);
                                  //
                                  CartAPI().addToCart(m).then((value) {
                                    Provider.of<UpdateCartData>(context,
                                            listen: false)
                                        .incrementCounter()
                                        .then((value) {
                                      Provider.of<UpdateCartData>(context,
                                              listen: false)
                                          .showCartorNot()
                                          .then((value) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Cart Updated".toString()),
                                              duration: Duration(seconds: 1)),
                                        );
                                      });
                                    });
                                  });
                                });
                              },
                              child: Text(
                                "Update",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                              ))),
                    ])))));
  }
}
