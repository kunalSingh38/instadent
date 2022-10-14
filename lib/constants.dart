// ignore_for_file: prefer_const_constructors, dead_code, prefer_interpolation_to_compose_strings
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/cart/cart_view.dart';
import 'package:instadent/category/sub_categories.dart';
import 'package:instadent/main.dart';
import 'package:instadent/zoom_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const URL = "https://dev.techstreet.in/idc/public/api/v1/";
const searchHint = "Search for gutta percha, files & more";
const whatsAppNo = "919899339093";
showLaoding(context) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SizedBox(
              height: 40,
              width: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CircularProgressIndicator(),
                  Text("Loading...")
                ],
              ),
            ),
          ));
}

Widget cacheImage(String imageUrl) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: BoxFit.fill,
    errorWidget: (context, url, error) {
      return Image.asset(
        "assets/logo.png",
      );
    },
  );
}

capitalize(str) {
  return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
}

Widget bottomSheet() =>
    Consumer<UpdateCartData>(builder: (context, viewModel, child) {
      return viewModel.counterShowCart
          ? InkWell(
              onTap: () {
                if (int.parse(viewModel.counter.toString()) > 0) {
                  Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CartView()))
                      .then((value) {
                    Provider.of<UpdateCartData>(context, listen: false)
                        .incrementCounter();
                    Provider.of<UpdateCartData>(context, listen: false)
                        .showCartorNot();
                  });
                }
              },
              child: Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal[800],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.counter.toString() + " item",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              Text(
                                "₹ " + viewModel.counterPrice.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "View Cart",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                            Icon(
                              Icons.arrow_right,
                              color: Colors.white,
                              size: 25,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SizedBox();
    });

String removeNull(String data) {
  return data == "null" ? "" : double.parse(data.toString()).toStringAsFixed(0);
}

TextStyle textStyle1 = TextStyle(color: Colors.white);

Future<void> showProdcutDetails(
    BuildContext context,
    Map m,
    bool inStock,
    TextEditingController controller,
    List productItems,
    FirebaseDynamicLinks dynamicLinks,
    bool show) async {
  String group_Data = m['group_price']
      .toString()
      .replaceAll("&#8377;", "₹")
      .replaceAll("<br/>", ",")
      .toString();

  print(group_Data);

  List data = group_Data.split(",");
  data.removeLast();
  double height = 220;
  double heightMain = 1.4;
  print(data);

  String disccount = m['discount_percentage'].toString();
  // String temp = m['item_discount'].toString().split("%")[0].toString();

  // if (temp.split(".")[0].toString() == "0" &&
  //     temp.split(".")[1].toString() == "00") {
  //   disccount = "0";
  // } else if (temp.split(".")[1].toString() == "00") {
  //   disccount = temp.split(".")[0].toString();
  // } else {
  //   disccount = temp;
  // }

  List multipleImages = [];
  multipleImages.add({"image": m['product_image'].toString()});

  if (m.containsKey("multiple_images")) {
    multipleImages.addAll(m['multiple_images']);
  }

  List otherDetails = [];
  if (m.containsKey("other_details")) {
    otherDetails.addAll(m['other_details']);
  }

  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height / heightMain,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: height,
                            child: multipleImages.length > 0
                                ? ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: multipleImages
                                        .map((e) => InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ZoomImages(
                                                              images:
                                                                  multipleImages,
                                                              selectedIndex:
                                                                  multipleImages
                                                                      .indexOf(
                                                                          e),
                                                            )));
                                              },
                                              child: Card(
                                                  elevation: 8,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                  ),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: SizedBox(
                                                        height: 200,
                                                        width: 220,
                                                        child: cacheImage(
                                                            e['image']
                                                                .toString()),
                                                      ))),
                                            ))
                                        .toList(),
                                  )
                                : Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    elevation: 8,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: cacheImage(
                                            m['product_image'].toString())),
                                  ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(m['product_name'].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18)),
                              ),
                              Expanded(
                                  child: InkWell(
                                onTap: () async {
                                  await createDynamicLink(dynamicLinks)
                                      .then((value) async {
                                    await FlutterShare.share(
                                        title: m['product_name'].toString(),
                                        // text: 'Example share text',
                                        linkUrl: value,
                                        chooserTitle:
                                            m['product_name'].toString(),
                                        text: "InstaDent Product");
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  child: CircleAvatar(
                                    radius: 19,
                                    backgroundColor: Colors.white,
                                    child: Image.asset(
                                      "assets/share2.png",
                                      scale: 2.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          m['packing_info'] == null
                              ? SizedBox()
                              : Column(
                                  children: [
                                    Text(m['packing_info'].toString()),
                                    SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Text(
                                        "₹" +
                                            double.parse(m['discount_price']
                                                    .toString())
                                                .toStringAsFixed(0),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text("₹" + removeNull(m['mrp'].toString()),
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                            fontSize: 14)),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    disccount == "0"
                                        ? SizedBox()
                                        : Container(
                                            width: 65,
                                            decoration: BoxDecoration(
                                                color: Colors.teal,
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                double.parse(disccount
                                                            .toString())
                                                        .toStringAsFixed(0) +
                                                    "% OFF",
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              show
                                  ? SizedBox()
                                  : Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: inStock
                                            ? Container(
                                                width: 75,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[350],
                                                    border: Border.all(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 2, 8, 2),
                                                  child: Center(
                                                    child: Text(
                                                      "Out of Stock",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ))
                                            : Container(
                                                width: 75,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                    color: m['quantity'] > 0
                                                        ? Colors.teal[400]
                                                        : Colors.teal[50],
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF004D40)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: m['quantity'] > 0
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
                                                                        8,
                                                                        4,
                                                                        2,
                                                                        4),
                                                                child: Text(
                                                                  "-",
                                                                  style:
                                                                      textStyle1,
                                                                ),
                                                              ),
                                                              Text(
                                                                m['quantity']
                                                                    .toString(),
                                                                style:
                                                                    textStyle1,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        2,
                                                                        4,
                                                                        8,
                                                                        4),
                                                                child: Text(
                                                                  "+",
                                                                  style:
                                                                      textStyle1,
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
                                                                  child:
                                                                      InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await setQunatity(
                                                                      productItems
                                                                          .indexOf(
                                                                              m),
                                                                      false,
                                                                      productItems,
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                              )),
                                                              Expanded(
                                                                  child:
                                                                      InkWell(
                                                                onTap:
                                                                    () async {
                                                                  setState(() {
                                                                    controller
                                                                        .clear();
                                                                  });
                                                                  await manuallyUpdateQuantity(
                                                                      productItems
                                                                          .indexOf(
                                                                              m),
                                                                      productItems,
                                                                      context,
                                                                      controller);
                                                                },
                                                                child: Container(
                                                                    color: Colors
                                                                        .transparent),
                                                              )),
                                                              Expanded(
                                                                  child:
                                                                      InkWell(
                                                                onTap:
                                                                    () async {
                                                                  await setQunatity(
                                                                      productItems
                                                                          .indexOf(
                                                                              m),
                                                                      true,
                                                                      productItems,
                                                                      context);
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
                                                              productItems
                                                                  .indexOf(m),
                                                              true,
                                                              productItems,
                                                              context);
                                                        },
                                                        child: Stack(
                                                          alignment: Alignment
                                                              .topRight,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      8,
                                                                      2,
                                                                      8,
                                                                      2),
                                                              child: Center(
                                                                child: Text(
                                                                  "ADD",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
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
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          data.length == 0
                              ? SizedBox()
                              : Column(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: data
                                          .map(
                                            (e) => Column(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        e.toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.white),
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                )
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    SizedBox(
                                      height: 12,
                                    ),
                                  ],
                                ),
                          m['warranty_month'].toString() != "0"
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Warranty Duration",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 17)),
                                        Text(
                                            m['warranty_month'].toString() +
                                                " Months",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          m['expiry_date'] == null || m['expiry_date'] == ""
                              ? SizedBox()
                              : Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Expiry Date",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 17)),
                                        Text(m['expiry_date'].toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            )),
                                      ],
                                    ),
                                  ],
                                ),
                          Divider(
                            thickness: 0.9,
                            height: 30,
                          ),
                          Text("Description",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black)),
                          SizedBox(
                            height: 2,
                          ),
                          Text(m['short_description'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.grey)),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: otherDetails
                                .map((e) => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(e['title'].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                                color: Colors.black)),
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Text(e['description'].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                                color: Colors.grey)),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ))
                                .toList(),
                          ),
                       Divider(
                            thickness: 0.9,
                            height: 30,
                          ),
                          Text("You may also like", style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black)),
                                   SizedBox(
                            height: 10,
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: productItems.map((e) {
                                  bool inStock =
                                      e['is_stock'] == 1 ? false : true;

                                  String disccount =
                                      e['discount_percentage'].toString();

                                  // if (temp
                                  //             .split(".")[
                                  //                 0]
                                  //             .toString() ==
                                  //         "0" &&
                                  //     temp
                                  //             .split(
                                  //                 ".")[1]
                                  //             .toString() ==
                                  //         "00") {
                                  //   disccount = "0";
                                  // } else if (temp
                                  //         .split(".")[1]
                                  //         .toString() ==
                                  //     "00") {
                                  //   disccount = temp
                                  //       .split(".")[0]
                                  //       .toString();
                                  // } else {
                                  //   disccount = temp;
                                  // }
                                  // return Text("data");
                                  return singleProductDesign(
                                      context,
                                      e,
                                      inStock,
                                      controller,
                                      productItems,
                                      dynamicLinks,
                                      disccount,
                                      true);
                                }).toList()),
                              )),
                        ]),
                  )),
            );
          }));
}

Widget backIcon(context) {
  return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: SizedBox(
        width: 80,
        child: Icon(
          Icons.arrow_back_outlined,
          color: Colors.black,
          size: 27,
        ),
      ));
}

Widget allCategoryGrid(
    List categoryList, BuildContext context, double fontSize) {
  return GridView.count(
    crossAxisCount: 4,
    mainAxisSpacing: 0,
    crossAxisSpacing: 12,
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
                        builder: (context) => SubCategoriesScreen(
                              catName: e['category_name'].toString(),
                              catId: e['id'].toString(),
                              bannerImage: e['category_banner'].toString(),
                            ))).then((value) {
                  Provider.of<UpdateCartData>(context, listen: false)
                      .incrementCounter();
                  Provider.of<UpdateCartData>(context, listen: false)
                      .showCartorNot();
                });
              },
              child: Column(
                children: [
                  Expanded(
                      flex: 2,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.tealAccent[50],
                          ),
                          child: e['icon'] == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    "assets/no_image.jpeg",
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: cacheImage(e['icon'].toString())

                                  //  Image.network(
                                  //   e['icon'].toString(),
                                  //   fit: BoxFit.cover,
                                  //   loadingBuilder:
                                  //       (context, child, loadingProgress) {
                                  //     if (loadingProgress == null) return child;
                                  //     return Center(
                                  //       child: CircularProgressIndicator(
                                  //         value: loadingProgress
                                  //                     .expectedTotalBytes !=
                                  //                 null
                                  //             ? loadingProgress
                                  //                     .cumulativeBytesLoaded /
                                  //                 loadingProgress
                                  //                     .expectedTotalBytes!
                                  //             : null,
                                  //       ),
                                  //     );
                                  //   },
                                  // ),
                                  ))),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      child: Text(
                    e['category_name'] == ""
                        ? "No Name"
                        : e['category_name'].toString().toUpperCase(),
                    softWrap: true,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: fontSize * 0.5),
                  ))
                ],
              ),
            ))
        .toList(),
  );
}

Widget allProductsList(
    List productItems,
    BuildContext context,
    TextEditingController controller,
    double ratio,
    FirebaseDynamicLinks dynamicLinks) {
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 0,
      crossAxisSpacing: 0,
      childAspectRatio: ratio,
      physics: ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: productItems.map((e) {
        bool inStock = e['is_stock'] == 1 ? false : true;

        String disccount = "";
        String temp = e['item_discount'].toString().split("%")[0];

        if (temp.split(".")[0].toString() == "0" &&
            temp.split(".")[1].toString() == "00") {
          disccount = "0";
        } else if (temp.split(".")[1].toString() == "00") {
          disccount = temp.split(".")[0].toString();
        } else {
          disccount = temp;
        }

        return singleProductDesign(context, e, inStock, controller,
            productItems, dynamicLinks, disccount, false);
      }).toList(),
    );
  });
}

Widget singleProductDesign(
        BuildContext context,
        Map e,
        bool inStock,
        TextEditingController controller,
        List productItems,
        FirebaseDynamicLinks dynamicLinks,
        String disccount,
        bool fromHomePage) =>
    StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Stack(
        children: [
          InkWell(
            onTap: () async {
              await showProdcutDetails(context, e, inStock, controller,
                  productItems, dynamicLinks, false);
            },
            child: Container(
              width: fromHomePage ? 170 : null,
              height: fromHomePage ? 250 : null,
              decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD6D6D6), width: 0.3)),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: cacheImage(e['product_image'].toString())),
                  ),
                  // SizedBox(
                  //   height: 2,
                  // ),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 20, 5, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e['product_name'].toString() + "\n\n",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                        // Text(
                        //   "500 g",
                        //   textAlign: TextAlign.left,
                        //   maxLines: 1,
                        //   style: TextStyle(
                        //       fontWeight: FontWeight.w300, fontSize: 12),
                        // ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "₹" +
                                            double.parse(e['discount_price']
                                                    .toString())
                                                .toStringAsFixed(0),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                    Text(
                                        "₹" +
                                            double.parse(e['mrp'].toString())
                                                .toStringAsFixed(0),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey))
                                  ],
                                ),
                              ],
                            ),
                            inStock
                                ? SizedBox()
                                : Container(
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
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 4, 2, 4),
                                                    child: Text(
                                                      "-",
                                                      style: textStyle1,
                                                    ),
                                                  ),
                                                  Text(
                                                    e['quantity'].toString(),
                                                    style: textStyle1,
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(2, 4, 8, 4),
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
                                                          false,
                                                          productItems,
                                                          context);
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
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
                                                              .indexOf(e),
                                                          productItems,
                                                          context,
                                                          controller);
                                                    },
                                                    child: Container(
                                                        color:
                                                            Colors.transparent),
                                                  )),
                                                  Expanded(
                                                      child: InkWell(
                                                    onTap: () async {
                                                      await setQunatity(
                                                          productItems
                                                              .indexOf(e),
                                                          true,
                                                          productItems,
                                                          context);
                                                    },
                                                    child: Container(
                                                        color:
                                                            Colors.transparent),
                                                  ))
                                                ],
                                              )
                                            ],
                                          )
                                        : InkWell(
                                            onTap: () async {
                                              await setQunatity(
                                                  productItems.indexOf(e),
                                                  true,
                                                  productItems,
                                                  context);
                                            },
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 2, 8, 2),
                                                  child: Center(
                                                    child: Text(
                                                      "ADD",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.teal[900]),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
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
                          ],
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
          disccount == "0"
              ? SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(
                        " " +
                            double.parse(disccount.toString())
                                .toStringAsFixed(0) +
                            "% OFF",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
          // Positioned(
          //   bottom: 8,
          //   right: 2,
          //   child: ),
          // e['is_favorite'] == 0
          //     ? SizedBox()
          //     : Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: Align(
          //           alignment: Alignment.topRight,
          //           child: Icon(
          //             Icons.star,
          //             color: Colors.amber,
          //           ),
          //         ),
          //       )
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: inStock
                  ? InkWell(
                      onTap: () async {
                        await showProdcutDetails(context, e, inStock,
                            controller, productItems, dynamicLinks, false);
                      },
                      child: Container(
                        color: Colors.white.withOpacity(0.6),
                        child: Center(
                          // child: Image.asset(
                          //   "assets/out-of-stock.png",
                          //   scale: 10,
                          //   color: Colors.black,
                          // ),
                          child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  "Out of Stock",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )),
                        ),
                      ),
                    )
                  : SizedBox(),
            ),
          ),
        ],
      );
    });
Future setQunatity(
    int index, bool action, List productItems, BuildContext context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getBool("loggedIn") ?? false) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Adding....".toString()),
        duration: Duration(seconds: 10),
      ),
    );
    print("loggedin");
    if (action) {
      productItems[index]['quantity'] = productItems[index]['quantity'] + 1;
      Map m = {
        "offer_price": productItems[index]['discount_price'].toString(),
        "rate": int.parse(productItems[index]['mrp'].toString().split(".")[0]),
        "quantity": productItems[index]['quantity'].toString(),
        "product_id": productItems[index]['product_id'].toString()
      };
      print(m);

      CartAPI().addToCart(m).then((value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Provider.of<UpdateCartData>(context, listen: false)
            .incrementCounter()
            .then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .showCartorNot()
              .then((value1) {});
        });
      });
    } else {
      productItems[index]['quantity'] = productItems[index]['quantity'] - 1;
      Map m = {
        "offer_price": productItems[index]['discount_price'].toString(),
        "rate": int.parse(productItems[index]['mrp'].toString().split(".")[0]),
        "quantity": productItems[index]['quantity'].toString(),
        "product_id": productItems[index]['product_id'].toString()
      };
      print(m);
      CartAPI().addToCart(m).then((value) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Provider.of<UpdateCartData>(context, listen: false)
            .incrementCounter()
            .then((value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .showCartorNot()
              .then((value) {
            // Navigator.of(context).pop();
          });
        });
      });
    }
  } else {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("Please log in to continue".toString()),
    //   ),
    // );
    showDialog(
        context: context,
        builder: (contextMy) => AlertDialog(
              title: Text("Login Required"),
              content: Text("Please log in to continue"),
              actions: [
                TextButton(
                    onPressed: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();

                      await prefs.clear().then((value) {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => SplashScreen()),
                                (route) => false);
                      });
                      Provider.of<UpdateCartData>(context, listen: false)
                          .changeSearchView(0);
                      Provider.of<UpdateCartData>(context, listen: false)
                          .showCartorNot();
                    },
                    child: Text("Continue Login"))
              ],
            ));
    Provider.of<UpdateCartData>(context, listen: false).changeSearchView(4);
  }
}

Future<void> manuallyUpdateQuantity(int index, List productItems,
    BuildContext context, TextEditingController controller) async {
  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 10,
                      right: 10),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[700])),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Adding....".toString()),
                                duration: Duration(seconds: 10),
                              ),
                            );
                            productItems[index]['quantity'] =
                                int.parse(controller.text);

                            Map m = {
                              "offer_price": productItems[index]
                                      ['discount_price']
                                  .toString(),
                              "rate": int.parse(productItems[index]['mrp']
                                  .toString()
                                  .split(".")[0]),
                              "quantity":
                                  productItems[index]['quantity'].toString(),
                              "product_id":
                                  productItems[index]['product_id'].toString()
                            };
                            print(m);
                            //
                            CartAPI().addToCart(m).then((value) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              Provider.of<UpdateCartData>(context,
                                      listen: false)
                                  .incrementCounter()
                                  .then((value) {
                                Provider.of<UpdateCartData>(context,
                                        listen: false)
                                    .showCartorNot()
                                    .then((value) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Cart Updated".toString()),
                                        duration: Duration(seconds: 1)),
                                  );
                                });
                              });
                            });
                          },
                          child: Text(
                            "Update",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ))),
                ),
              ])));
}

Widget loadingProducts(String message) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(
          height: 20,
        ),
        Text(
          message,
          style: TextStyle(
              fontWeight: FontWeight.w700, fontSize: 14, color: Colors.grey),
        )
      ],
    ),
  );
}

Future<String> createDynamicLink(FirebaseDynamicLinks dynamicLinks) async {
  final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
    uriPrefix: "https://instadent.page.link",
    // socialMetaTagParameters: SocialMetaTagParameters(
    //   imageUrl: Uri.parse(
    //     "https://idcweb.techstreet.in/#/home",
    //   ),
    //   description: "test description",
    //   title: "lead",
    // ),
    link: Uri.parse(
      "https://instadent.page.link/xEYL",
    ),
    iosParameters: IOSParameters(
      bundleId: 'com.wlo.smartCollect',
      minimumVersion: '1.0.1',
      appStoreId: '1624261118',
    ),
    androidParameters: AndroidParameters(
      packageName: "com.wlo.wlo_master",
    ),
  );

  final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(dynamicLinkParameters);
  print(shortLink.shortUrl.toString());
  return shortLink.shortUrl.toString();
}
