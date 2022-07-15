// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

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
                        Text(
                            "Raw mango is an aromatic fruit which is liked by all for its tart flavour. The colour varies in shades of greens and the inner flesh is white in colour. It can be used in raw salads, aam panna, mango Dal, mango rice etc.",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Colors.grey)),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Nutrient Value & Benefits",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 17)),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                            "Contains Folic Acid, Vitamin C, Vitamin K, .Vitamin C act as a powerful antioxidants and also helps formation of collagen that is responsible for skin and hair health.",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Colors.grey)),
                      ]),
                )),
          ));
}
