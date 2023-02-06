import 'package:biz_sales_admin/apis/customer_api.dart';
import 'package:biz_sales_admin/customer/image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

import '../constants.dart';

class CustomerDetails extends StatefulWidget {
  Map m = {};
  CustomerDetails({required this.m});

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  bool isLoading = true;
  Map map = {};
  GlobalKey<FormState> form = GlobalKey();

  Widget dataShow(String label, value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400),
        ),
        SizedBox(
          height: 5,
        ),
        Text(
          value == null ? "-" : value.toString().toUpperCase(),
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  List docList = [];
  List linkedCat = [];
  void reload() async {
    CustomerAPI().customerDetailsApi(widget.m['id'].toString()).then((value) {
      setState(() {
        docList.clear();
        linkedCat.clear();
        map = value;
        docList.add({
          "image":
              "https://dev.techstreet.in/tayal/public/assets/images/${map['userdetails1']['upload_photo']}",
          "title": "Photo"
        });
        docList.add({
          "image":
              "https://dev.techstreet.in/tayal/public/assets/images/${map['userdetails1']['upload_gst_certificate']}",
          "title": "GST Cert."
        });
        docList.add({
          "image":
              "https://dev.techstreet.in/tayal/public/assets/images/${map['userdetails1']['upload_pancard']}",
          "title": "PAN"
        });
        docList.add({
          "image":
              "https://dev.techstreet.in/tayal/public/assets/images/${map['userdetails1']['upload_agriculture_license']}",
          "title": "LIC"
        });
        linkedCat.addAll(map['usercat']);
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reload();
  }

  String selectedExpenseValue = "1";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        // extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.teal[300],
          elevation: 0,
        ),
        body: isLoading
            ? loadingProducts("Loading customer details...")
            : Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.white70,
                        blurRadius: 10.0,
                      ),
                    ],
                    color: Colors.teal[300],
                  ),
                  height: MediaQuery.of(context).size.height / 6.5,
                  width: MediaQuery.of(context).size.width,
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ImageView(
                                            path: map['userdetails']
                                                    ['profile_image']
                                                .toString())));
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 90,
                                child: CircleAvatar(
                                  radius: 85,
                                  foregroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                    map['userdetails']['profile_image']
                                        .toString(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: TextButton(
                            //       child: Text(
                            //     "Update Authorization",
                            //     style: TextStyle(color: Colors.blue),
                            //   )),
                            // ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Authorize Status"),
                                        Row(
                                          children: [
                                            map['userdetails']['authorize'] == 0
                                                ? Text("New User")
                                                : map['userdetails']
                                                            ['authorize'] ==
                                                        1
                                                    ? Row(
                                                        children: [
                                                          Text("Authorized"),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            "assets/auth.png",
                                                            scale: 20,
                                                          ),
                                                        ],
                                                      )
                                                    : Row(
                                                        children: [
                                                          Text(
                                                              "Not Authorized"),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            "assets/notauth.png",
                                                            scale: 20,
                                                          ),
                                                        ],
                                                      ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                TextEditingController reason =
                                                    TextEditingController();
                                                await showModalBottomSheet(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20.0))),
                                                    backgroundColor:
                                                        Colors.white,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) =>
                                                        StatefulBuilder(builder:
                                                            (BuildContext context,
                                                                StateSetter
                                                                    setState) {
                                                          return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      20,
                                                                      30,
                                                                      20,
                                                                      20),
                                                              child:
                                                                  SingleChildScrollView(
                                                                      child:
                                                                          Form(
                                                                key: form,
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                          "Customer Authorize",
                                                                          style:
                                                                              GoogleFonts.montserrat(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          )),
                                                                      SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Card(
                                                                        elevation:
                                                                            5,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(0),
                                                                          child:
                                                                              FormField(
                                                                            builder:
                                                                                (FormFieldState state) {
                                                                              return InputDecorator(
                                                                                decoration: InputDecoration(
                                                                                  fillColor: Colors.white,
                                                                                  filled: true,
                                                                                  labelText: "Action*",
                                                                                  labelStyle: TextStyle(color: Colors.grey[800], fontSize: 16, fontWeight: FontWeight.w700),
                                                                                  isDense: true,
                                                                                  contentPadding: EdgeInsets.all(10),
                                                                                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                                                                                ),
                                                                                child: DropdownButtonHideUnderline(
                                                                                  child: DropdownButton(
                                                                                    isExpanded: true,
                                                                                    value: selectedExpenseValue,
                                                                                    isDense: true,
                                                                                    onChanged: (newValue) {
                                                                                      setState(() {
                                                                                        selectedExpenseValue = newValue.toString();
                                                                                      });
                                                                                    },
                                                                                    items: [
                                                                                      {
                                                                                        "item": "Accept",
                                                                                        "val": "1"
                                                                                      },
                                                                                      {
                                                                                        "item": "Reject",
                                                                                        "val": "2"
                                                                                      }
                                                                                    ].map((value) {
                                                                                      return DropdownMenuItem(
                                                                                        value: value['val'].toString(),
                                                                                        child: Text(
                                                                                          value['item'].toString(),
                                                                                          style: TextStyle(color: Colors.black),
                                                                                        ),
                                                                                      );
                                                                                    }).toList(),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Card(
                                                                        elevation:
                                                                            5,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                            side: BorderSide(color: Color(0xFFEEEEEE))),
                                                                        child:
                                                                            TextFormField(
                                                                          controller:
                                                                              reason,
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w700),
                                                                          maxLines:
                                                                              3,
                                                                          validator:
                                                                              (value) {
                                                                            if (value == null ||
                                                                                value.isEmpty) {
                                                                              return 'Required Field';
                                                                            }
                                                                            return null;
                                                                          },
                                                                          decoration:
                                                                              InputDecoration(
                                                                            border:
                                                                                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                                            contentPadding:
                                                                                EdgeInsets.all(10),
                                                                            // filled: true,
                                                                            // fillColor: Colors.teal[50],
                                                                            focusedBorder:
                                                                                OutlineInputBorder(borderSide: BorderSide(color: Colors.lightBlue), borderRadius: BorderRadius.circular(10)),
                                                                            hintText:
                                                                                "Reason",
                                                                            hintStyle: TextStyle(
                                                                                color: Colors.grey,
                                                                                fontSize: 16,
                                                                                fontWeight: FontWeight.w400),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                          width: MediaQuery.of(context).size.width /
                                                                              1.15,
                                                                          height:
                                                                              45,
                                                                          child:
                                                                              ElevatedButton(
                                                                            style: ButtonStyle(
                                                                                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                )),
                                                                                backgroundColor: MaterialStateProperty.all(Colors.teal[700])),
                                                                            onPressed:
                                                                                () {
                                                                              if (form.currentState!.validate()) {
                                                                                showLaoding(context);
                                                                                CustomerAPI().customerAuthorize(widget.m['id'].toString(), selectedExpenseValue, widget.m['customer_type'], reason.text.toString()).then((value) {
                                                                                  Navigator.of(context, rootNavigator: true).pop();
                                                                                  Navigator.of(context, rootNavigator: false).pop();
                                                                                  reload();
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: Duration(seconds: 1), content: Text(value.toString())));
                                                                                });
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              "Send",
                                                                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white),
                                                                            ),
                                                                          ))
                                                                    ]),
                                                              )));
                                                        }));
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.green[900],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Text(
                                                    "Update",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // SizedBox(
                                    //     // width:
                                    //     //     MediaQuery.of(context).size.width /
                                    //     //         1.15,
                                    //     // height: 45,
                                    //     child: ElevatedButton(
                                    //   style: ButtonStyle(
                                    //       shape: MaterialStateProperty.all(
                                    //           RoundedRectangleBorder(
                                    //         borderRadius:
                                    //             BorderRadius.circular(10.0),
                                    //       )),
                                    //       backgroundColor:
                                    //           MaterialStateProperty.all(
                                    //               Colors.teal[700])),
                                    //   onPressed: () {},
                                    //   child: Text(
                                    //     "Update",
                                    //     style: TextStyle(
                                    //         fontWeight: FontWeight.w400,
                                    //         fontSize: 16,
                                    //         color: Colors.white),
                                    //   ),
                                    // ))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Personal Details"),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "User Name",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Row(
                                          children: [
                                            Text("Enabled"),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Image.asset(
                                              "assets/checked.png",
                                              scale: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      map['userdetails']['username'] == null
                                          ? "-"
                                          : map['userdetails']['username']
                                              .toString()
                                              .toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    dataShow("Customer Type",
                                        map['userdetails']['customer_type']),
                                    dataShow("Clinic Name",
                                        map['userdetails']['clinic_name']),
                                    dataShow("Mobile Number",
                                        map['userdetails']['mobile']),
                                    dataShow("Email ID",
                                        map['userdetails']['email']),
                                    dataShow("Full Address",
                                        map['userdetails']['address']),
                                    dataShow("Landmark",
                                        map['userdetails']['landmark']),
                                    dataShow("Pincode",
                                        map['userdetails']['pincode']),
                                    dataShow(
                                        "GSTN", map['userdetails']['gstin']),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text("Uploaded Documents"),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.count(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 5,
                                    shrinkWrap: true,
                                    crossAxisSpacing: 5,
                                    childAspectRatio: 0.8,
                                    scrollDirection: Axis.vertical,
                                    physics: ClampingScrollPhysics(),
                                    children: docList
                                        .map(
                                          (e) => InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ImageView(
                                                              path: e['image']
                                                                  .toString())));
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey)),
                                              child: Column(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1.2,
                                                    child: cacheImage(
                                                        e['image'].toString()),
                                                  ),
                                                  Container(
                                                      color: Colors.white,
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(e['title']),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList()),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text("Linked Categories"),
                            SizedBox(
                              height: 10,
                            ),
                            ListView(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                children: linkedCat
                                    .map((e) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              (linkedCat.indexOf(e) + 1)
                                                      .toString() +
                                                  " : " +
                                                  e['category_name'].toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            )
                                          ],
                                        ))
                                    .toList())
                          ]),
                    ))
              ]));
  }
}
