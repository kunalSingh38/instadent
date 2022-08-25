// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/brand/brand_products.dart';
import 'package:instadent/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletons/skeletons.dart';
import 'package:collection/collection.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool isLoading = true;
  bool isSearching = false;
  List brandList = [];
  List brandListCopy = [];
  TextEditingController searching = TextEditingController();

  getBrandList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      print("with login");
      CategoryAPI().brandCategorywithLogin().then((value) {
        setState(() {
          brandList.clear();
          brandList.addAll(value);
          brandListCopy.addAll(value);
          brandList.sort((a, b) => a['name'].compareTo(b['name']));
          brandListCopy.sort((a, b) => a['name'].compareTo(b['name']));
          isLoading = false;
        });
      });
    } else {
      print("without login");
      CategoryAPI().brandCategorywithoutLogin().then((value) {
        setState(() {
          brandList.clear();
          brandList.addAll(value);
          brandListCopy.addAll(value);
          isLoading = false;
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      searching.clear();
    });
    getBrandList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
        return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 60,
              title: isSearching
                  ? Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Color(0xFFEEEEEE))),
                      child: TextFormField(
                        controller: searching,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            List dummyListData = [];

                            brandListCopy.forEach((item) {
                              if (item['name']
                                  .toString()
                                  .toUpperCase()
                                  .contains(value.toUpperCase())) {
                                dummyListData.add(item);
                              }
                            });
                            setState(() {
                              brandList.clear();
                              brandList.addAll(dummyListData.toSet().toList());
                            });
                            return;
                          } else {
                            setState(() {
                              brandList.clear();
                              brandList.addAll(brandListCopy);
                            });
                          }
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: EdgeInsets.all(15),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.lightBlue),
                                borderRadius: BorderRadius.circular(10)),
                            hintText: "Search brands",
                            hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  isSearching = !isSearching;
                                  searching.clear();
                                  brandList.clear();
                                  brandList.addAll(brandListCopy);
                                });
                              },
                            )),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Brands",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black)),
                          SizedBox(
                            height: 6,
                          ),
                          Text("Curated with the best range of brands",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  color: Colors.black)),
                        ],
                      ),
                    ),
              actions: [
                isSearching
                    ? SizedBox()
                    : InkWell(
                        onTap: () {
                          setState(() {
                            isSearching = !isSearching;
                            searching.clear();
                          });
                        },
                        child: Image.asset(
                          "assets/search.png",
                          scale: 25,
                        )),
                PopupMenuButton(
                    onSelected: (value) {
                      setState(() {
                        if (value == "A-Z") {
                          brandList
                              .sort((a, b) => a['name'].compareTo(b['name']));
                          brandListCopy
                              .sort((a, b) => a['name'].compareTo(b['name']));
                        } else if (value == "Z-A") {
                          brandList
                              .sort((a, b) => b['name'].compareTo(a['name']));
                          brandListCopy
                              .sort((a, b) => b['name'].compareTo(a['name']));
                        }
                      });
                    },
                    icon: Image.asset(
                      "assets/filter.png",
                      scale: 24,
                    ),
                    itemBuilder: ((context) => ["A-Z", "Z-A"]
                        .map((e) => PopupMenuItem(
                              child: Text(
                                e,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              value: e,
                            ))
                        .toList()))
              ],
            ),
            // bottomNavigationBar:
            //     viewModel.counterShowCart ? bottomSheet() : null,
            body: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(15, 25, 15, 0),
                  child: SingleChildScrollView(
                    child: isLoading
                        ? loadingProducts("Getting your InstaDent brands")
                        : Column(
                            children: [
                              GridView.count(
                                crossAxisCount: 4,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.6,
                                physics: ClampingScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                children: brandList
                                    .map((e) => InkWell(
                                          onTap: () {
                                            print(e);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BrandProducts(m: e)));
                                          },
                                          child: Column(
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      child:
                                                          e['product_image'] ==
                                                                  null
                                                              ? ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: Image
                                                                      .asset(
                                                                    "assets/logo.png",
                                                                    // fit: BoxFit.,
                                                                  ),
                                                                )
                                                              : ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child: Image
                                                                      .network(
                                                                    e['product_image']
                                                                        .toString(),
                                                                    // fit: BoxFit
                                                                    //     .cover,
                                                                    loadingBuilder:
                                                                        (context,
                                                                            child,
                                                                            loadingProgress) {
                                                                      if (loadingProgress ==
                                                                          null)
                                                                        return child;
                                                                      return Center(
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          value: loadingProgress.expectedTotalBytes != null
                                                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                                              : null,
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ))),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Expanded(
                                                  child: Text(
                                                e['name'] == ""
                                                    ? "No Name"
                                                    : e['name'].toString(),
                                                softWrap: true,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11),
                                              ))
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
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
                    child:
                        viewModel.counterShowCart ? bottomSheet() : SizedBox())
              ],
            ));
      }),
    );
  }
}
