// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, sort_child_properties_last, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/brand/brand_products.dart';
import 'package:instadent/constants.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({Key? key}) : super(key: key);

  @override
  _OffersScreenState createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool isLoading = true;
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
    print("Offer 4");
  }

  List brandImageList = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      searching.clear();
    });
    OtherAPI().homePageBanner("brand").then((value) {
      setState(() {
        brandImageList.addAll(value);
      });
    });
    getBrandList();
  }

  @override
  Widget build(BuildContext context) {
    double unitHeightValue =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.02
            : MediaQuery.of(context).size.width * 0.02;
    return SafeArea(
      child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
        return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              toolbarHeight: 50,
              title: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Brands",
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                    SizedBox(
                      height: 2,
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
            body: RefreshIndicator(
              onRefresh: () async {
                getBrandList();
              },
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                    child: isLoading
                        ? loadingProducts("Getting your InstaDent brands")
                        : Column(
                            children: [
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: searching,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
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
                                        brandList.addAll(
                                            dummyListData.toSet().toList());
                                      });
                                      return;
                                    } else {
                                      setState(() {
                                        brandList.clear();
                                        brandList.addAll(brandListCopy);
                                      });
                                    }
                                  },
                                  // autofocus: true,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      contentPadding: EdgeInsets.all(15),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlue),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      hintText: "Search brands",
                                      hintStyle: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300),
                                      suffixIcon: IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            searching.clear();
                                            brandList.clear();
                                            brandList.addAll(brandListCopy);
                                          });
                                        },
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                flex: 10,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      brandImageList.length == 0
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color: Colors.grey[50]),
                                                child: ImageSlideshow(
                                                  width: double.infinity,
                                                  height: 180,
                                                  initialPage: 0,
                                                  indicatorColor: Colors.blue,
                                                  indicatorBackgroundColor:
                                                      Colors.grey,
                                                  children: brandImageList
                                                      .map((e) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 22),
                                                            child: SizedBox(
                                                              height: 140,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width /
                                                                  0.5,
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  child: cacheImage(
                                                                      e['mobile_banner']
                                                                          .toString())),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onPageChanged: (value) {},
                                                  autoPlayInterval: 3000,
                                                  isLoop: true,
                                                ),
                                              ),
                                            ),
                                      brandList.length == 0
                                          ? Center(
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      "assets/noData.jpg",
                                                      // scale: 0,
                                                    ),
                                                    Text(
                                                      "No data found",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: GridView.count(
                                                crossAxisCount: 4,
                                                mainAxisSpacing: 0,
                                                crossAxisSpacing: 10,
                                                childAspectRatio: 0.6,
                                                physics:
                                                    ClampingScrollPhysics(),
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                children: brandList
                                                    .map((e) => InkWell(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        BrandProducts(
                                                                            m: e)));
                                                          },
                                                          child: Column(
                                                            children: [
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Container(
                                                                      width: MediaQuery.of(context).size.width,
                                                                      decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey,
                                                                            width: 0.5),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      child: e['product_image'] == null
                                                                          ? ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: Image.asset(
                                                                                "assets/logo.png",
                                                                                // fit: BoxFit.,
                                                                              ),
                                                                            )
                                                                          : ClipRRect(borderRadius: BorderRadius.circular(10), child: cacheImage(e['product_image'].toString())))),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Expanded(
                                                                  child: Text(
                                                                e['name'] == ""
                                                                    ? "No Name"
                                                                    : e['name']
                                                                        .toString(),
                                                                softWrap: true,
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
                                                                            .bold,
                                                                    fontSize:
                                                                        unitHeightValue *
                                                                            0.7),
                                                              ))
                                                            ],
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              viewModel.counterShowCart
                                  ? SizedBox(
                                      height: 55,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: viewModel.counterShowCart
                          ? bottomSheet()
                          : SizedBox())
                ],
              ),
            ));
      }),
    );
  }
}
