// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/constants.dart';
import 'package:provider/provider.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({Key? key}) : super(key: key);

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomSheet: bottomSheet(),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 60),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("All categories",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(
                  height: 6,
                ),
                Text("Curated with the best range of products",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w300, fontSize: 12)),
                SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.55,
                  physics: ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: List.generate(
                      9,
                      (index) => Column(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.teal[50],
                                      ),
                                      child: Image.asset("assets/logo.png"))),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                  child: Text(
                                "Vefitables & Fruits abcd",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11),
                              ))
                            ],
                          )).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
