// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/category_api.dart';
import 'package:instadent/category/sub_categories.dart';
import 'package:instadent/constants.dart';
import 'package:provider/provider.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomSheet: bottomSheet(),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : categoryList.length == 0
                ? Center(
                    child: Text("No Category found."),
                  )
                : Padding(
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
                            children: categoryList
                                .map((e) => InkWell(
                                      onTap: () {
                                        print(e['id'].toString());
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SubCategoriesScreen(
                                                      catName:
                                                          e['category_name']
                                                              .toString(),
                                                      catId: e['id'].toString(),
                                                    )));
                                      },
                                      child: Column(
                                        children: [
                                          Expanded(
                                              flex: 2,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.teal[50],
                                                  ),
                                                  child: e['icon'] == null
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.asset(
                                                            "assets/no_image.jpeg",
                                                            fit: BoxFit.fill,
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child: Image.network(
                                                            e['icon']
                                                                .toString(),
                                                            // fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    loadingProgress) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  value: loadingProgress
                                                                              .expectedTotalBytes !=
                                                                          null
                                                                      ? loadingProgress
                                                                              .cumulativeBytesLoaded /
                                                                          loadingProgress
                                                                              .expectedTotalBytes!
                                                                      : null,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ))),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Expanded(
                                              child: Text(
                                            e['category_name'].toString(),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11),
                                          ))
                                        ],
                                      ),
                                    ))
                                .toList(),
                          )
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
