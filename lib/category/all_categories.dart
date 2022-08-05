// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/add_to_cart_helper.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/category/sub_categories.dart';
import 'package:instadent/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  bool isLoading = true;
  List categoryList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CategoryAPI().cartegoryList().then((value) {
      setState(() {
        categoryList.clear();
        categoryList.addAll(value);
        isLoading = false;
      });
    });
    Provider.of<UpdateCartData>(context, listen: false).incrementCounter();
    Provider.of<UpdateCartData>(context, listen: false).showCartorNot();
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
              title: Padding(
                padding: const EdgeInsets.only(top: 20),
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
            body: Stack(
              children: [
                isLoading
                    ? loadingProducts("Getting your InstaDent products")
                    : Padding(
                        padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              allCategoryGrid(categoryList, context),
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
