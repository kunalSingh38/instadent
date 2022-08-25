// ignore_for_file: sort_child_properties_last, prefer_const_constructors, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/address.dart';
import 'package:instadent/cart/order_history.dart';
import 'package:instadent/contact_us.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/login.dart';
import 'package:instadent/main.dart';
import 'package:instadent/policy_view.dart';
import 'package:instadent/user_profile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List yourInfo = [
    {"title": "Profile", "id": "4", "icon": "account.png"},
    {"title": "Order History", "id": "1", "icon": "order.png"},
    {"title": "Address Book", "id": "2", "icon": "address.png"},
    {"title": "Share the app", "id": "3", "icon": "share.png"}
  ];
  List otherInfo = [
    {
      "title": "About Us",
      "id": "1",
      "icon": "aboutus.png",
      "data": "aboutus.html"
    },
    {
      "title": "Privacy Policy",
      "id": "5",
      "icon": "policy.png",
      "data": "privacy.html"
    },
    {
      "title": "Shipping Policy",
      "id": "6",
      "icon": "shipping.png",
      "data": "shipping.html"
    },
    {
      "title": "Refund & Replacement",
      "id": "7",
      "icon": "refund.png",
      "data": "refund.html"
    },
    {
      "title": "Terms & Condition",
      "id": "8",
      "icon": "terms.png",
      "data": "term_condition.html"
    },
    {"title": "Rate us on Play Store", "id": "2", "icon": "star.png"},
    {"title": "Contact Us", "id": "4", "icon": "contact.png"},
    {"title": "Logout", "id": "3", "icon": "logout.png"}
  ];

  List list = [
    {"title": "Wallet", "id": "1", "icon": "wallet.png"},
    {"title": "Support", "id": "2", "icon": "support.png"},
    {"title": "Payment", "id": "3", "icon": "payment.png"}
  ];

  String phoneNumber = "";
  String appVersion = "";
  getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      phoneNumber = prefs.getString("userPhoneNo").toString();
      appVersion = packageInfo.version.toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 50,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("My Account",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.black)),
                Text("InstaDent\nv" + appVersion,
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.grey)),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                phoneNumber == "null"
                    ? Column(
                        children: [
                          Text(
                              "Log in or sign up to view your complete profile",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, fontSize: 15)),
                          SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 1.25,
                              height: 45,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: BorderSide(
                                                  color: Color(0xFF1B5E20)))),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white)),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      DashboardState.currentTab = 0;
                                    });

                                    await prefs.clear().then((value) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      SplashScreen()),
                                              (route) => false);
                                    });
                                    Provider.of<UpdateCartData>(context,
                                            listen: false)
                                        .showCartorNot();
                                  },
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.green[900],
                                        fontSize: 16),
                                  ))),
                        ],
                      )
                    : Text(phoneNumber,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w400, fontSize: 18)),
                SizedBox(
                  height: 20,
                ),
                phoneNumber == "null"
                    ? SizedBox()
                    : Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.teal[50],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: list
                                      .map(
                                        (e) => Column(
                                          children: [
                                            Image.asset(
                                              "assets/" + e['icon'].toString(),
                                              scale: 18,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(e['title']),
                                          ],
                                        ),
                                      )
                                      .toList()),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                Text("YOUR INFORMATION",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey)),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: yourInfo
                      .map((e) => phoneNumber == "null" && e['id'] == "4" ||
                              phoneNumber == "null" && e['id'] == "1"
                          ? SizedBox()
                          : ListTile(
                              dense: true,
                              minLeadingWidth: 2,
                              leading: Image.asset(
                                "assets/" + e['icon'].toString(),
                                scale: 25,
                              ),
                              title: Text(
                                e['title'],
                                style: TextStyle(fontSize: 16),
                              ),
                              onTap: () async {
                                switch (e['id'].toString()) {
                                  case "4":
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                UserProfileViewUpdate())));
                                    break;
                                  case "1":
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                OrderHistoryScreen())));
                                    break;
                                  case "2":
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                AddressListScreen())));
                                    break;
                                  case "3":
                                    await FlutterShare.share(
                                      title: 'InstaDent App',
                                      linkUrl:
                                          'https://play.google.com/store/apps/details?id=com.tayal.tayalFintech',
                                    );
                                    break;
                                }
                              },
                            ))
                      .toList(),
                ),
                SizedBox(
                  height: 25,
                ),
                Text("OTHER INFORMATION",
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.grey)),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: otherInfo.map((e) {
                    int index = otherInfo.indexOf(e);
                    return phoneNumber == "null" && e['id'] == "3"
                        ? SizedBox()
                        : ListTile(
                            onTap: () async {
                              switch (e['id']) {
                                case "1":
                                case "5":
                                case "6":
                                case "7":
                                case "8":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Policy_View(
                                              policy: e['title'].toString(),
                                              data: e['data'].toString())));
                                  break;

                                case "3":
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: Text(
                                              "Do you want to logout?",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text("Cancel")),
                                              TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    setState(() {
                                                      DashboardState
                                                          .currentTab = 0;
                                                    });

                                                    await prefs
                                                        .clear()
                                                        .then((value) {
                                                      Navigator.of(context,
                                                              rootNavigator:
                                                                  true)
                                                          .pushAndRemoveUntil(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          SplashScreen()),
                                                              (route) => false);
                                                    });
                                                    Provider.of<UpdateCartData>(
                                                            context,
                                                            listen: false)
                                                        .showCartorNot();
                                                  },
                                                  child: Text("Logout"))
                                            ],
                                          ));

                                  break;
                                case "4":
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ContactUsScreen()));
                                  break;
                              }
                            },
                            dense: true,
                            minLeadingWidth: 2,
                            leading: Image.asset(
                              "assets/" + e['icon'].toString(),
                              scale: 25,
                            ),
                            title: Text(
                              e['title'],
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                  }).toList(),
                ),
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: Text(
                    "Copyright© 2022 InstaDent. Designed By TechStreet.in",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
