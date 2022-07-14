// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/address.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchCont = TextEditingController();

  String defaultAddress = "Select Address";
  List addressList = [];
  Future<void> getAddressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      LoginAPI().addressList().then((value) {
        setState(() {
          addressList.clear();
          addressList.addAll(value);
        });

        addressList.forEach((element) {
          if (element['is_default'] == 1) {
            setState(() {
              defaultAddress = element['address'].toString() +
                  ", " +
                  element['pincode'].toString();
            });
          }
        });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: Colors.teal[100],
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Close this app?",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Image.asset(
                        "assets/logo.png",
                        scale: 2,
                      )
                    ],
                  ),
                  content: Text("Are you sure you want to exit.",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        )),
                    TextButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(color: Colors.black),
                        )),
                  ],
                ));
      },
      child: SafeArea(
        child: Scaffold(
          bottomSheet: bottomSheet(),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delivery in 11 mintues",
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800, fontSize: 20)),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddressListScreen()))
                          .then((value) => getAddressList());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          flex: 15,
                          child: Text(capitalize(defaultAddress.toString()),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w400, fontSize: 15)),
                        ),
                        Expanded(child: Icon(Icons.arrow_drop_down))
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Color(0xFFEEEEEE))),
                  child: TextFormField(
                    controller: searchCont,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.all(2),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.lightBlue),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Search for atta, dal, coke and more",
                      hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                      prefixIcon: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 35,
                          )),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("data"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
