// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Future<void> showProdcutDetails(context, m) async {
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
                        Text("Product details",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18)),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Description",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17)),
                        SizedBox(
                          height: 8,
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
