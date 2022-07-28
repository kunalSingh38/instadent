// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/cart/cart_view.dart';
import 'package:provider/provider.dart';

const URL = "https://dev.techstreet.in/idc/public/api/v1/";

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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.teal,
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
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              "₹ " + viewModel.counterPrice.toString(),
                              style: TextStyle(color: Colors.white),
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
            )
          : SizedBox();
    });

String removeNull(String data) {
  return data == "null" ? "" : data.toString();
}

Future<void> showProdcutDetails(context, m) async {
  String group_Data = m['group_price']
      .toString()
      .replaceAll("&#8377;", "₹")
      .replaceAll("<br/>", ",")
      .toString();

  List data = group_Data.split(",");
  data.removeLast();

  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
            height: MediaQuery.of(context).size.height / 1.7,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 220,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                4,
                                (index) => Card(
                                  elevation: 8,
                                  child: Container(
                                    height: 200,
                                    width: 200,
                                    child: Image.asset("assets/logo.png"),
                                  ),
                                ),
                              ).toList()),
                        ),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Product details",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18)),
                            RichText(
                              text: TextSpan(
                                text: '',
                                style: DefaultTextStyle.of(context).style,
                                children: [
                                  TextSpan(
                                      text: "₹" +
                                          removeNull(
                                              m['item_price'].toString()),
                                      style: TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey,
                                          fontSize: 16)),
                                  TextSpan(
                                      text: "  ₹" +
                                          m['discount_price'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "L x W x H (cm)",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              removeNull(m['item_length'].toString()) +
                                  " x " +
                                  removeNull(m['item_width'].toString()) +
                                  " x " +
                                  removeNull(m['item_height'].toString()),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Weight (g)",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              removeNull(m['item_weight'].toString()),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
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
                                                          color: Colors.white),
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

                        Text("Description",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(m['short_description'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Colors.grey)),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Text("Nutrient Value & Benefits",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w400, fontSize: 17)),
                        // SizedBox(
                        //   height: 8,
                        // ),
                        // Text(
                        //     "Contains Folic Acid, Vitamin C, Vitamin K, .Vitamin C act as a powerful antioxidants and also helps formation of collagen that is responsible for skin and hair health.",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w400,
                        //         fontSize: 15,
                        //         color: Colors.grey)),
                      ]),
                )),
          ));
}

Widget backIcon(context) {
  return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Icon(
        Icons.arrow_back_outlined,
        color: Colors.black,
        size: 27,
      ));
}
