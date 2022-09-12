import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class BrandProducts extends StatefulWidget {
  Map m = {};
  BrandProducts({required this.m});

  @override
  _BrandProductsState createState() => _BrandProductsState();
}

class _BrandProductsState extends State<BrandProducts> {
  List productList = [];
  bool isLoading = true;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OtherAPI().brandProductData(widget.m['id'].toString()).then((value) {
      setState(() {
        isLoading = false;
        productList.clear();
        productList.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UpdateCartData>(builder: (context, viewModel, child) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: backIcon(context),
            elevation: 3,
            title: Text(
              widget.m['name'].toString() +
                  " (" +
                  productList.length.toString() +
                  ")",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 14),
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
          // bottomNavigationBar: viewModel.counterShowCart ? bottomSheet() : null,
          body: Stack(
            children: [
              isLoading
                  ? loadingProducts(
                      "Getting " + widget.m['name'].toString() + " products")
                  : productList.length == 0
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/noData.jpg"),
                              Text(
                                "No data found",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              allProductsList(productList, context, controller,
                                  0.8, dynamicLinks),
                              viewModel.counterShowCart
                                  ? SizedBox(
                                      height: 60,
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: viewModel.counterShowCart ? bottomSheet() : SizedBox())
            ],
          ));
    });
  }
}
