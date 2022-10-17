// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/constants.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  bool isLoading = true;
  List categoryList = [];
  List categoryListCopy = [];
  bool isSearching = false;
  TextEditingController searching = TextEditingController();
  @override
  void initState() {
    super.initState();
    CategoryAPI().cartegoryList().then((value) {
      setState(() {
        categoryList.clear();
        categoryList.addAll(value);
        categoryListCopy.clear();
        categoryListCopy.addAll(value);
        isLoading = false;
      });
    });
    Provider.of<UpdateCartData>(context, listen: false).incrementCounter();
    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
  }

  @override
  Widget build(BuildContext context) {
    double unitHeightValue =
        MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.02
            : MediaQuery.of(context).size.width * 0.02;
    return RefreshIndicator(
      onRefresh: () async {
        CategoryAPI().cartegoryList().then((value) {
          setState(() {
            categoryList.clear();
            categoryList.addAll(value);
            categoryListCopy.clear();
            categoryListCopy.addAll(value);
            isLoading = false;
          });
        });
        Provider.of<UpdateCartData>(context, listen: false).incrementCounter();
        Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
      },
      child: SafeArea(
        child: Consumer<UpdateCartData>(builder: (context, viewModel, child) {
          return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                toolbarHeight: 60,
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
                          ))
                ],
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

                              categoryListCopy.forEach((item) {
                                if (item['category_name']
                                    .toString()
                                    .toUpperCase()
                                    .contains(value.toUpperCase())) {
                                  dummyListData.add(item);
                                }
                              });
                              setState(() {
                                categoryList.clear();
                                categoryList
                                    .addAll(dummyListData.toSet().toList());
                              });
                              return;
                            } else {
                              setState(() {
                                categoryList.clear();
                                categoryList.addAll(categoryListCopy);
                              });
                            }
                          },
                          // autofocus: true,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(15),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue),
                                  borderRadius: BorderRadius.circular(10)),
                              hintText: "Search categories",
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
                                    categoryList.clear();
                                    categoryList.addAll(categoryListCopy);
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
                            Text("All categories",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black)),
                            SizedBox(
                              height: 6,
                            ),
                            Text("Curated with the best range of products",
                                style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
              ),
              // bottomNavigationBar:
              //     viewModel.counterShowCart ? bottomSheet() : null,
              body: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.8,
                    child: Stack(
                      children: [
                        isLoading
                            ? loadingProducts("Getting your InstaDent products")
                            : Padding(
                                padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                                child: categoryList.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset("assets/noData.jpg"),
                                            Text(
                                              "No data found",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            allCategoryGrid(categoryList, context,
                                                unitHeightValue),
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
                                : SizedBox())
                      ],
                    ),
                  ),
                ],
              ));
        }),
      ),
    );
  }
}
