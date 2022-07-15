// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/add_update_address.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String phoneNumber = "";
  int groupValue = 0;
  List addressList = [];
  Future<void> getAddressList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("loggedIn") ?? false) {
      LoginAPI().addressList().then((value) {
        setState(() {
          addressList.clear();

          value.sort((a, b) => a['id'].compareTo(b['id']));
          addressList.addAll(value);
        });

        addressList.forEach((element) {
          if (element['is_default'] == 1) {
            setState(() {
              groupValue = element['id'];
            });
          }
        });
      });
    }
  }

  getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = pref.getString("userPhoneNo").toString();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAddressList();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          phoneNumber == "null"
              ? SizedBox()
              : TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddUpdateAddressScreen(
                                  update: false,
                                  map: {},
                                ))).then((value) {
                      getAddressList();
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text("ADD"))
        ],
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
              size: 22,
            )),
        elevation: 3,
        leadingWidth: 30,
        title: const Text(
          "Address List",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: phoneNumber == "null"
            ? Column(
                children: [
                  Text("Log in or sign up to view your complete profile",
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
                                      borderRadius: BorderRadius.circular(10.0),
                                      side: BorderSide(
                                          color: Color(0xFF1B5E20)))),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white)),
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
                                          builder: (context) => SplashScreen()),
                                      (route) => false);
                            });
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
            : ListView(
                children: addressList
                    .map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ListTile(
                          minLeadingWidth: 2,
                          leading: SizedBox(
                            height: 20,
                            width: 20,
                            child: Radio(
                                value: int.parse(e['id'].toString()),
                                groupValue: groupValue,
                                onChanged: (val) {
                                  // setState(() {
                                  //   groupValue = int.parse(
                                  //       val.toString());
                                  // });
                                }),
                          ),
                          onTap: () {},
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(capitalize(e['address'].toString() +
                                  ", " +
                                  e['pincode'].toString())),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  e['is_default'] == 1
                                      ? Container(
                                          width: 70,
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text(
                                              "Set Default",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Setting Default Address."),
                                                  duration:
                                                      Duration(seconds: 1)),
                                            );
                                            LoginAPI()
                                                .setDefaultAddress(
                                                    e['id'].toString())
                                                .then((value) {
                                              if (value) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(e[
                                                                  'address_type']
                                                              .toString() +
                                                          " set as default address."),
                                                      duration:
                                                          Duration(seconds: 1)),
                                                );
                                                getAddressList();
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text("Error"),
                                                      duration:
                                                          Duration(seconds: 1)),
                                                );
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 70,
                                            decoration: BoxDecoration(
                                                color: Colors.green[800],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Set Default",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddUpdateAddressScreen(
                                                        update: true,
                                                        map: e,
                                                      )))
                                          .then((value) => getAddressList());
                                    },
                                    child: Container(
                                      width: 70,
                                      decoration: BoxDecoration(
                                          color: Colors.blue[800],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Edit",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  e['is_default'] == 1
                                      ? SizedBox(
                                          width: 70,
                                        )
                                      : InkWell(
                                          onTap: () async {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                action: SnackBarAction(
                                                    label: "Remove",
                                                    onPressed: () {
                                                      LoginAPI()
                                                          .removeAddress(e['id']
                                                              .toString())
                                                          .then((value) {
                                                        if (value) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          1),
                                                              content: Text(
                                                                  "Address Removed."),
                                                            ),
                                                          );
                                                          getAddressList();
                                                        }
                                                      });
                                                    }),
                                                content:
                                                    Text("Removing Address."),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 70,
                                            decoration: BoxDecoration(
                                                color: Colors.red[800],
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                "Remove",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        )
                                ],
                              )
                            ],
                          ),
                          horizontalTitleGap: 20,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(e['address_type'].toString()),
                              SizedBox(
                                width: 5,
                              ),
                              e['is_default'] == 1
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[350],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Default",
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[800]),
                                        ),
                                      ),
                                    )
                                  : SizedBox()
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
