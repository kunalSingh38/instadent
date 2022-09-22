// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/account.dart';
import 'package:instadent/add_to_cart_helper.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/product_model.dart';
import 'package:instadent/search/search.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';

class SubCategoriesScreen extends StatefulWidget {
  String catName;
  String catId;
  String bannerImage;

  SubCategoriesScreen(
      {required this.catName, required this.catId, required this.bannerImage});

  @override
  _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  TextEditingController controller = TextEditingController();
  bool isLoadingLeft = true;
  bool isLoadingRight = false;
  List subCategoryList = [];
  List productItems = [];
  String selectedSubCategory = "";
  String pincode = "";
  // final dbHelper = DatabaseHelper.instance;
  Future getSubCategoryList() async {
    CategoryAPI().subCartegoryList(widget.catId.toString()).then((value) async {
      print(value);
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
          isLoadingLeft = false;
          currentSelection = subCategoryList[0]['id'].toString();
        });

        await getSubCategoryProducts(subCategoryList[0]['id'].toString());
      } else {
        setState(() {
          isLoadingLeft = false;
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
    print(id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoadingRight = true;
    });
    if (pref.getBool("loggedIn") ?? false) {
      CategoryAPI()
          .productList(id, pref.getString("pincode").toString())
          .then((value) {
        setState(() {
          isLoadingRight = false;
        });
        if (value['ErrorCode'] == 0) {
          if (value['ItemResponse']['category_products'].length > 0) {
            setState(() {
              productItems.clear();
              productItems.addAll(value['ItemResponse']['category_products']);
            });
            print(productItems[0]);
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
        setState(() {
          isLoadingRight = false;
        });
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

  String currentSelection = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("banner image " + widget.bannerImage);
    getSubCategoryList();
    Provider.of<UpdateCartData>(context, listen: false).incrementCounter();
    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateCartData>(builder: (context, viewModel, child) {
      return Scaffold(
          // bottomNavigationBar: viewModel.counterShowCart ? bottomSheet() : null,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: backIcon(context),
            elevation: 3,
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
                onTap: () {
                  Provider.of<UpdateCartData>(context, listen: false)
                      .changeSearchView(2);
                },
                child: Image.asset(
                  "assets/search.png",
                  scale: 25,
                ),
              )
            ],
          ),
          body: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
            return Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  right: BorderSide(
                                      color: Color(0xFFD6D6D6), width: 0.3)),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  isLoadingLeft
                                      ? GridView.count(
                                          crossAxisCount: 1,
                                          mainAxisSpacing: 0,
                                          crossAxisSpacing: 0,
                                          childAspectRatio: 0.7,
                                          physics: ClampingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          children: List.generate(
                                              10,
                                              (index) => Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                            bottom: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey))),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Expanded(
                                                            flex: 2,
                                                            child: SkeletonItem(
                                                              child:
                                                                  CircleAvatar(
                                                                      maxRadius:
                                                                          30,
                                                                      backgroundColor:
                                                                          Colors
                                                                              .red,
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
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2),
                                                            child: Text(
                                                              "",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
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
                                          childAspectRatio: 0.6,
                                          physics: ClampingScrollPhysics(),
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          children: subCategoryList
                                              .map((e) => InkWell(
                                                    onTap: () async {
                                                      Scrollable.ensureVisible(
                                                          e['key']
                                                              .currentContext,
                                                          duration: Duration(
                                                              milliseconds:
                                                                  1300));
                                                      subCategoryList
                                                          .forEach((element) {
                                                        setState(() {
                                                          element['selected'] =
                                                              false;
                                                        });
                                                      });
                                                      setState(() {
                                                        e['selected'] = true;
                                                        productItems.clear();
                                                        // isLoading = true;
                                                        selectedSubCategory =
                                                            "";
                                                        selectedSubCategory =
                                                            e['category_name']
                                                                .toString();
                                                        currentSelection =
                                                            e['id'].toString();
                                                      });

                                                      await getSubCategoryProducts(
                                                          e['id'].toString());
                                                    },
                                                    child: Stack(
                                                      key: e['key'],
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      width:
                                                                          0.5,
                                                                      color: Colors
                                                                          .grey))),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomCenter,
                                                                    children: [
                                                                      CircleAvatar(
                                                                        backgroundColor: e['selected']
                                                                            ? Colors.greenAccent[100]
                                                                            : Colors.grey[200],
                                                                        radius:
                                                                            30,
                                                                      ),
                                                                      AnimatedAlign(
                                                                        alignment: e['selected']
                                                                            ? Alignment.center
                                                                            : Alignment.bottomCenter,
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                        curve: Curves
                                                                            .fastOutSlowIn,
                                                                        child:
                                                                            ClipRRect(
                                                                          borderRadius: BorderRadius.only(
                                                                              bottomLeft: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10)),
                                                                          child:
                                                                              Image.network(
                                                                            e['icon'].toString(),
                                                                            scale: e['selected']
                                                                                ? 1
                                                                                : 2,
                                                                            errorBuilder: (context,
                                                                                error,
                                                                                stackTrace) {
                                                                              return Align(alignment: Alignment.center, child: Image.asset("assets/logo.png"));
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )

                                                                  // e['icon'] ==
                                                                  //             null ||
                                                                  //         e['icon'] ==
                                                                  //             ""
                                                                  //     ? CircleAvatar(
                                                                  //         maxRadius:
                                                                  //             30,
                                                                  //         backgroundColor:
                                                                  //             Colors
                                                                  //                 .red,
                                                                  //         backgroundImage:
                                                                  //             AssetImage(
                                                                  //           "assets/no_image.jpeg",
                                                                  //         ))
                                                                  //     : CircleAvatar(
                                                                  //         backgroundColor:
                                                                  //             Colors.grey[
                                                                  //                 50],
                                                                  //         maxRadius:
                                                                  //             40,
                                                                  //         backgroundImage:
                                                                  //             NetworkImage(
                                                                  //           e['icon']
                                                                  //               .toString(),

                                                                  //           // fit: BoxFit.cover,
                                                                  //         ))
                                                                  ),
                                                              SizedBox(
                                                                height: 5,
                                                              ),
                                                              Expanded(
                                                                  child:
                                                                      Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        2),
                                                                child: Text(
                                                                  capitalize(e[
                                                                          'category_name']
                                                                      .toString()),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      fontWeight: e[
                                                                              'selected']
                                                                          ? FontWeight
                                                                              .w600
                                                                          : FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12),
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
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child:
                                                                    Container(
                                                                  height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height,
                                                                  width: 3,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .red,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          bottomLeft:
                                                                              Radius.circular(10))),
                                                                ),
                                                              )
                                                            : SizedBox()
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                  viewModel.counterShowCart
                                      ? SizedBox(
                                          height: 70,
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ))),
                    Expanded(
                      child: isLoadingRight
                          ? Center(
                              child: loadingProducts("Getting " +
                                  selectedSubCategory.toString() +
                                  " products"),
                            )
                          : LiquidPullToRefresh(
                              animSpeedFactor: 5,
                              springAnimationDurationInMilliseconds: 800,
                              onRefresh: () async {
                                // print(currentSelection);
                                await getSubCategoryProducts(currentSelection);
                              },
                              child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 140,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child:
                                                widget.bannerImage.toString() ==
                                                        ""
                                                    ? Image.asset(
                                                        "assets/logo.png",
                                                        fit: BoxFit.contain,
                                                      )
                                                    : Image.network(
                                                        widget.bannerImage
                                                            .toString(),
                                                        fit: BoxFit.fill,
                                                      )),
                                        allProductsList(productItems, context,
                                            controller, 0.56, dynamicLinks),
                                        viewModel.counterShowCart
                                            ? SizedBox(
                                                height: 70,
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  )),
                            ),
                      flex: 4,
                    ),
                  ],
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child:
                        viewModel.counterShowCart ? bottomSheet() : SizedBox())
              ],
            );
          }));
    });
  }
}
