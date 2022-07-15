// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/category/product_details.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/search/search.dart';
import 'package:provider/provider.dart';

class SubCategoriesScreen extends StatefulWidget {
  String catName;
  String catId;

  SubCategoriesScreen({required this.catName, required this.catId});

  @override
  _SubCategoriesScreenState createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  bool itemAdded = false;
  TextStyle textStyle1 = TextStyle(color: Colors.white);
  bool isLoading = true;
  List subCategoryList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CategoryAPI().subCartegoryList(widget.catId.toString()).then((value) {
      if (value.length > 0) {
        setState(() {
          subCategoryList.clear();

          for (var element in value) {
            if (value.indexOf(element) == 0) {
              element['selected'] = true;
            } else {
              element['selected'] = false;
            }
          }

          subCategoryList.addAll(value);

          isLoading = false;
        });
      }
    });
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
        title: Text(
          widget.catName + " (" + subCategoryList.length.toString() + ")",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
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
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              right: BorderSide(
                                  color: Color(0xFFD6D6D6), width: 0.3)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: viewModel.counterShowCart ? 70 : 0),
                          child: GridView.count(
                            crossAxisCount: 1,
                            mainAxisSpacing: 0,
                            crossAxisSpacing: 0,
                            childAspectRatio: 0.7,
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: subCategoryList
                                .map((e) => InkWell(
                                      onTap: () {
                                        subCategoryList.forEach((element) {
                                          setState(() {
                                            element['selected'] = false;
                                          });
                                        });
                                        setState(() {
                                          e['selected'] = true;
                                        });
                                      },
                                      child: Stack(
                                        alignment: Alignment.bottomCenter,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: e['icon'] == null ||
                                                          e['icon'] == ""
                                                      ? CircleAvatar(
                                                          backgroundColor:
                                                              Colors.grey[50],
                                                          maxRadius: 30,
                                                          backgroundImage:
                                                              AssetImage(
                                                            "assets/no_image.jpeg",
                                                          ))
                                                      : CircleAvatar(
                                                          backgroundColor:
                                                              Colors.grey[50],
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
                                                  child: Text(
                                                e['category_name'].toString(),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12),
                                              ))
                                            ],
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
                                                    width: 5,
                                                    decoration: BoxDecoration(
                                                        color: Colors.teal,
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
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: List.generate(
                        6,
                        (index) => Stack(
                          children: [
                            InkWell(
                              onTap: () async {
                                Map m = {};
                                await showProdcutDetails(context, m);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xFFD6D6D6), width: 0.3)),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                          child:
                                              Image.asset("assets/logo.png")),
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
                                            "Natural Tattva Rock Salt",
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            "500 g",
                                            textAlign: TextAlign.left,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("₹420",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 12)),
                                                  Text("₹550",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 11,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          color: Colors.grey))
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
                                        bottomRight: Radius.circular(10))),
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
                                    bottom: 22, right: 10),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      itemAdded = !itemAdded;
                                    });
                                  },
                                  child: Container(
                                    width: 65,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: itemAdded
                                            ? Colors.teal[400]
                                            : Colors.teal[50],
                                        border: Border.all(
                                            color: Color(0xFF004D40)),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: itemAdded
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 5, 8, 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "-",
                                                  style: textStyle1,
                                                ),
                                                Text(
                                                  "1",
                                                  style: textStyle1,
                                                ),
                                                Text(
                                                  "+",
                                                  style: textStyle1,
                                                ),
                                              ],
                                            ),
                                          )
                                        : Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 5, 8, 5),
                                                child: Center(
                                                  child: Text(
                                                    "ADD",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            Colors.teal[900]),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
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
                            )
                          ],
                        ),
                      ).toList(),
                    ),
                  )),
              flex: 3,
            ),
          ],
        );
      }),
    );
  }
}
