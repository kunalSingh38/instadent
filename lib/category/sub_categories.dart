// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/add_to_cart_helper.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/product_model.dart';
import 'package:instadent/search/search.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

class SubCategoriesScreen extends StatefulWidget {
  String catName;
  String catId;

  SubCategoriesScreen({required this.catName, required this.catId});

  @override
  _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  TextEditingController controller = TextEditingController();
  bool isLoading = true;
  List subCategoryList = [];
  List productItems = [];
  String selectedSubCategory = "";
  String pincode = "";
  final dbHelper = DatabaseHelper.instance;
  Future getSubCategoryList() async {
    CategoryAPI().subCartegoryList(widget.catId.toString()).then((value) async {
      if (value.length > 0) {
        setState(() {
          subCategoryList.clear();

          for (var element in value) {
            element['key'] = GlobalKey();

            if (value.indexOf(element) == 0) {
              element['selected'] = true;
            } else {
              element['selected'] = false;
            }
          }

          subCategoryList.addAll(value);
          selectedSubCategory = subCategoryList[0]['category_name'].toString();
          isLoading = false;
        });
        await getSubCategoryProducts(subCategoryList[0]['id'].toString());
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Category Empty".toString()),
              duration: Duration(seconds: 2)),
        );
        Navigator.of(context).pop();
      }
    });
  }

  Future getSubCategoryProducts(String id) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getBool("loggedIn") ?? false) {
      CategoryAPI()
          .productList(id, pref.getString("pincode").toString())
          .then((value) {
        if (value['ErrorCode'] == 0) {
          if (value['ItemResponse']['category_products'].length > 0) {
            setState(() {
              productItems.clear();
              productItems.addAll(value['ItemResponse']['category_products']);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("No product found"),
                  duration: Duration(seconds: 2)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(value['ErrorMessage'].toString()),
                duration: Duration(seconds: 3)),
          );
        }
      });
    } else {
      CategoryAPI()
          .productListWithoutLogin(id, pref.getString("pincode").toString())
          .then((value) {
        if (value['ErrorCode'] == 0) {
          if (value['ItemResponse']['category_products'].length > 0) {
            setState(() {
              productItems.clear();
              productItems.addAll(value['ItemResponse']['category_products']);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("No product found"),
                  duration: Duration(seconds: 2)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(value['ErrorMessage'].toString()),
                duration: Duration(seconds: 3)),
          );
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getSubCategoryList();
    Provider.of<UpdateCartData>(context, listen: false).incrementCounter();
    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
              size: 22,
            )),
        elevation: 3,
        leadingWidth: 30,
        title: BreadCrumb(
          items: <BreadCrumbItem>[
            BreadCrumbItem(
                content: Text(widget.catName,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 14))),
            BreadCrumbItem(
                content: Text(
                    selectedSubCategory.split(" ")[0] +
                        "..." +
                        " (" +
                        productItems.length.toString() +
                        ")",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 14))),
          ],
          divider: Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 12,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Image.asset(
              "assets/search.png",
              scale: 25,
            ),
          )
        ],
      ),
      body: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
        return Row(
          children: [
            Expanded(
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          right:
                              BorderSide(color: Color(0xFFD6D6D6), width: 0.3)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: viewModel.counterShowCart ? 70 : 0),
                      child: isLoading
                          ? GridView.count(
                              crossAxisCount: 1,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 0.7,
                              // physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: List.generate(
                                  10,
                                  (index) => Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    width: 0.5,
                                                    color: Colors.grey))),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: SkeletonItem(
                                                  child: CircleAvatar(
                                                      maxRadius: 30,
                                                      backgroundColor:
                                                          Colors.red,
                                                      backgroundImage:
                                                          AssetImage(
                                                        "assets/no_image.jpeg",
                                                      )),
                                                )),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Expanded(
                                                child: SkeletonItem(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2),
                                                child: Text(
                                                  "",
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12),
                                                ),
                                              ),
                                            )),
                                            // Divider(thickness: 0.5)
                                          ],
                                        ),
                                      )).toList(),
                            )
                          : GridView.count(
                              crossAxisCount: 1,
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              childAspectRatio: 0.7,
                              // physics: ClampingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: subCategoryList
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          Scrollable.ensureVisible(
                                              e['key'].currentContext,
                                              duration:
                                                  Duration(milliseconds: 1300));
                                          subCategoryList.forEach((element) {
                                            setState(() {
                                              element['selected'] = false;
                                            });
                                          });
                                          setState(() {
                                            e['selected'] = true;
                                            productItems.clear();
                                            // isLoading = true;
                                            selectedSubCategory = "";
                                            selectedSubCategory =
                                                e['category_name'].toString();
                                          });

                                          await getSubCategoryProducts(
                                              e['id'].toString());
                                        },
                                        child: Stack(
                                          key: e['key'],
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          width: 0.5,
                                                          color: Colors.grey))),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Expanded(
                                                      flex: 2,
                                                      child: e['icon'] ==
                                                                  null ||
                                                              e['icon'] == ""
                                                          ? CircleAvatar(
                                                              maxRadius: 30,
                                                              backgroundColor:
                                                                  Colors.red,
                                                              backgroundImage:
                                                                  AssetImage(
                                                                "assets/no_image.jpeg",
                                                              ))
                                                          : CircleAvatar(
                                                              backgroundColor:
                                                                  Colors
                                                                      .grey[50],
                                                              maxRadius: 30,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                e['icon']
                                                                    .toString(),
                                                                // fit: BoxFit.cover,
                                                              ))),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Expanded(
                                                      child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 2),
                                                    child: Text(
                                                      capitalize(
                                                          e['category_name']
                                                              .toString()),
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12),
                                                    ),
                                                  )),
                                                  SizedBox(
                                                    height: 10,
                                                  )
                                                  // Divider(thickness: 0.5)
                                                ],
                                              ),
                                            ),
                                            e['selected']
                                                ? Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      width: 3,
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10))),
                                                    ),
                                                  )
                                                : SizedBox()
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            ),
                    ))),
            Expanded(
              child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: viewModel.counterShowCart ? 70 : 0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.56,
                      // physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: productItems
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
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 15, 8, 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e['item_name'].toString(),
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
                                                                    .split(
                                                                        ".")[0],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 12)),
                                                        Text(
                                                            "₹" +
                                                                e['item_price']
                                                                    .toString()
                                                                    .split(
                                                                        ".")[0],
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 11,
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
                                                              productItems
                                                                  .indexOf(e),
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
                                                            controller.clear();
                                                          });
                                                          await manuallyUpdateQuantity(
                                                              productItems
                                                                  .indexOf(e));
                                                        },
                                                        child: Container(
                                                            color: Colors
                                                                .transparent),
                                                      )),
                                                      Expanded(
                                                          child: InkWell(
                                                        onTap: () async {
                                                          await setQunatity(
                                                              productItems
                                                                  .indexOf(e),
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
                                                  print("object");
                                                  await setQunatity(
                                                      productItems.indexOf(e),
                                                      true);
                                                },
                                                child: Stack(
                                                  alignment: Alignment.topRight,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(8, 2, 8, 2),
                                                      child: Center(
                                                        child: Text(
                                                          "ADD",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .teal[900]),
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5.0),
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.teal[900],
                                                        size: 10,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  e['is_stock'] != 1
                                      ? SizedBox()
                                      : Container(
                                          color: Colors.grey.withOpacity(0.5),
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
                  )),
              flex: 4,
            ),
          ],
        );
      }),
    );
  }

  Future setQunatity(int index, bool action) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (pref.getBool("loggedIn") ?? false) {
      setState(() {
        isLoading = true;
      });
      print("loggedin");
      if (action) {
        setState(() {
          productItems[index]['quantity'] = productItems[index]['quantity'] + 1;
          Map m = {
            "offer_price": productItems[index]['discount_price'].toString(),
            "rate": int.parse(
                productItems[index]['item_price'].toString().split(".")[0]),
            "quantity": productItems[index]['quantity'].toString(),
            "product_id": productItems[index]['id'].toString()
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
      } else {
        setState(() {
          productItems[index]['quantity'] = productItems[index]['quantity'] - 1;
          Map m = {
            "offer_price": productItems[index]['discount_price'].toString(),
            "rate": int.parse(
                productItems[index]['item_price'].toString().split(".")[0]),
            "quantity": productItems[index]['quantity'].toString(),
            "product_id": productItems[index]['id'].toString()
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
    } else {
      print("loggedout");

      if (action) {
        // dbHelper.deleteAll();
        productItems[index]['quantity'] = productItems[index]['quantity'] + 1;

        dbHelper.insert(DummyCart(
            productItems[index]['id'].toString(),
            productItems[index]['quantity'].toString(),
            productItems[index]['item_price'].toString(),
            productItems[index]['discount_price'].toString()));

        dbHelper.queryAllRows().then((value) {
          print(value);

          List temp = value;
          temp.forEach((element) {
            if (element['productId'].toString() ==
                productItems[index]['id'].toString()) {
              print("macthed");
              print(productItems[index]['quantity']);
              print(element['productQty']);
              print(productItems);
              print(element);
              print(index);
              setState(() {
                productItems[index]['quantity'] = element['productQty'];
              });
            }
          });
        });
      } else {
        //  productItems[index]['id'].toString(),
        //     productItems[index]['quantity'].toString(),
        //     productItems[index]['item_price'].toString(),
        //     productItems[index]['discount_price'].toString())
      }
    }
  }

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
                                  productItems[index]['quantity'] =
                                      int.parse(controller.text);

                                  Map m = {
                                    "offer_price": productItems[index]
                                            ['discount_price']
                                        .toString(),
                                    "rate": int.parse(productItems[index]
                                            ['item_price']
                                        .toString()
                                        .split(".")[0]),
                                    "quantity": productItems[index]['quantity']
                                        .toString(),
                                    "product_id":
                                        productItems[index]['id'].toString()
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
