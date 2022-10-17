import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:instadent/apis/cart_api.dart';

import 'constants.dart';

class BannerProductsView extends StatefulWidget {
  final String id;
  const BannerProductsView({required this.id, Key? key}) : super(key: key);

  @override
  State<BannerProductsView> createState() => _BannerProductsViewState();
}

class _BannerProductsViewState extends State<BannerProductsView> {
  @override
  void initState() {
    CartAPI().bannerCarusalProductList(widget.id.toString()).then((value) {
      setState(() {
        productItems.clear();
        productItems.addAll(value);
        loading = false;
      });
    });
    super.initState();
  }

  bool loading = true;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  List productItems = [];
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Banner products ",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Colors.black),

        ),
      ),
      body: loading
          ? Center(
              child: loadingProducts("Please wait, fetching your products"),
            )
          : productItems.isEmpty
              ? Center(child: loadingProducts("No products found!!"))
              : allProductsList(
                  productItems, context, controller, 0.6, dynamicLinks),
    );
  }
}
