// ignore_for_file: prefer_const_constructors, dead_code, prefer_interpolation_to_compose_strings
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:biz_sales_admin/UpdateCart.dart';

import 'package:biz_sales_admin/orders/orders_list.dart';
import 'package:biz_sales_admin/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// const URL = "https://dev.techstreet.in/idc/public/api/v1/";
const URL = "https://dev.techstreet.in/tayal/public/api/v1/";
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

String removeNull(String data) {
  return data == "null" ? "" : double.parse(data.toString()).toStringAsFixed(0);
}

TextStyle textStyle1 = TextStyle(color: Colors.white);

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
    uriPrefix: "https://instadentapp.page.link",
    // socialMetaTagParameters: SocialMetaTagParameters(
    //   imageUrl: Uri.parse(
    //     "https://idcweb.techstreet.in/#/home",
    //   ),
    //   description: "test description",
    //   title: "lead",
    // ),
    link: Uri.parse(
      "https://instadentapp.page.link/jTpt",
    ),
    iosParameters: IOSParameters(
      bundleId: 'com.wlo.smartCollect',
      minimumVersion: '1.0.1',
      appStoreId: '1624261118',
    ),
    androidParameters: AndroidParameters(
      packageName: "com.biz.biz_sales_admin",
    ),
  );

  final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(dynamicLinkParameters);
  //print(shortLink.shortUrl.toString());
  return shortLink.shortUrl.toString();
}
