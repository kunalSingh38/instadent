// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List items = [
    // "maggi",
    // "atta",
    // "shampu with conditionar",
    // "sugar",
    // "tea",
    // "biscuit"
  ];

  TextEditingController searchCont = TextEditingController();
  recentSearchItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    recentSearchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: bottomSheet(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Color(0xFFEEEEEE))),
            child: TextFormField(
              controller: searchCont,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.all(10),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                    borderRadius: BorderRadius.circular(10)),
                hintText: "Search for atta, dal, coke and more",
                hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
                suffixIcon: searchCont.text == ""
                    ? InkWell(
                        onTap: () {
                          if (searchCont.text.isNotEmpty) {
                            setState(() {
                              items.add(searchCont.text);
                              searchCont.clear();
                            });
                          }
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 30,
                            )),
                      )
                    : InkWell(
                        onTap: () {
                          setState(() {
                            searchCont.clear();
                          });
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Icon(
                              Icons.clear,
                              color: Colors.red,
                              size: 30,
                            )),
                      ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
        child: Column(
          children: [
            items.length == 0
                ? SizedBox()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Recent searches",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      InkWell(
                        child: Text(
                          "Clear",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          setState(() {
                            items.clear();
                          });
                        },
                      ),
                    ],
                  ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                height: 35,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(
                    width: 10,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          searchCont.clear();
                          searchCont.text = items[index].toString();
                        });
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              items[index].toString(),
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          )),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
