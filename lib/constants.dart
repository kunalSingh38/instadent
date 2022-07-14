// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/dashboard.dart';
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
          ? Padding(
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
            )
          : SizedBox();
    });
