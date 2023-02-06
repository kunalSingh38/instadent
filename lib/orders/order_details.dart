import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:biz_sales_admin/apis/orders_api.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderDetails extends StatefulWidget {
  Map m;
  OrderDetails({required this.m});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isLoading = true;
  Map _verticalGroupValue = {};
  List<Map<String, dynamic>> _status = [];
  late File file = File("path");
  Map map = {};
  List itemsList = [];
  String pickedBy = "";
  void loaddata() async {
    OrdersAPI().ordersDetailsApi(widget.m['id'].toString()).then((value) {
      setState(() {
        map = value;
        itemsList.clear();
        itemsList.addAll(value['order_items']);
        _verticalGroupValue = value['picker'][0];
        List temp = value['picker'];
        _status.clear();
        temp.forEach((element) {
          _status.add({
            "id": element['id'].toString(),
            "inventory_name": element['inventory_name'].toString()
          });
        });

        if (map['getPicker'] != null) {
          for (var i = 0; i < _status.length; i++) {
            if (_status[i]["id"] == map['getPicker']['picker_id'].toString()) {
              pickedBy = _status[i]['inventory_name'].toString();
            }
          }
        }
        isLoading = false;
      });
    });
  }

  Widget rows(String label, String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            data == "null" ? "" : data.toString().toUpperCase(),
            style: TextStyle(
                color: Colors.grey[900],
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        )
      ],
    );
  }

  void _setPath(List<int> filepath) async {
    bool permissionAccess = false;
    if (await Permission.storage.request().isGranted) {
      setState(() {
        permissionAccess = true;
      });
    }
    if (await Permission.manageExternalStorage.request().isGranted) {
      setState(() {
        permissionAccess = true;
      });
    }

    if (permissionAccess) {
      final externalDir = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();
      String fileName = DateTime.now().toString() + ".pdf";
      print(externalDir!.path + "/" + fileName);
      File file = new File(externalDir!.path + "/" + fileName);
      if (!await file.exists()) {
        await file.create();
      }
      await file.writeAsBytes(filepath).then((value) {
        print(value.path);
        OpenFilex.open(value.path);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loaddata();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  ReceivePort _port = ReceivePort();
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.grey[200],
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              isLoading
                  ? SizedBox()
                  : map['cust_orderdetails']['order_status_name'] ==
                              "Shipped" ||
                          map['cust_orderdetails']['order_status_name'] ==
                              "Delivered"
                      ? TextButton.icon(
                          onPressed: () {
                            showLaoding(context);
                            OrdersAPI()
                                .downloadInvoice(widget.m['id'].toString())
                                .then((value) {
                              Navigator.of(context, rootNavigator: true).pop();
                              _setPath(value);
                            });
                          },
                          icon: Icon(
                            Icons.download,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Invoice Download",
                            style: TextStyle(color: Colors.white),
                          ))
                      : SizedBox()
            ],
          ),
          body: isLoading
              ? loadingProducts("Loading order details...")
              : Stack(
                  children: [
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
                        height: MediaQuery.of(context).size.height / 4.5,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order status : ' +
                                    map['cust_orderdetails']
                                            ['order_status_name']
                                        .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                              Text(
                                'Created At : ${map['cust_orderdetails']['created_at'].toString()}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 16),
                              ),
                              Text(
                                "Order : ${widget.m["order_id"].toString()}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 28),
                              ),
                            ],
                          ),
                        )),
                    Padding(
                      padding: map['cust_orderdetails']['order_status_name'] ==
                              "Delivered"
                          ? const EdgeInsets.fromLTRB(20, 130, 20, 5)
                          : const EdgeInsets.fromLTRB(20, 130, 20, 70),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              // height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Text(
                                          "Payment Status",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        map['cust_orderdetails']
                                                    ['payment_status'] ==
                                                ""
                                            ? Text("N/A",
                                                style: TextStyle(
                                                    color: Colors.red))
                                            : Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/checked.png",
                                                    scale: 15,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(map['cust_orderdetails']
                                                          ['payment_status']
                                                      .toString()
                                                      .toUpperCase())
                                                ],
                                              ),
                                      ],
                                    )),
                                    Expanded(
                                        child: Column(
                                      children: [
                                        Text(
                                          "Payment Mode",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        map['cust_orderdetails']['pay_mode'] ==
                                                null
                                            ? Text("N/A",
                                                style: TextStyle(
                                                    color: Colors.red))
                                            : Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/rzp.png",
                                                    scale: 15,
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(map['cust_orderdetails']
                                                          ['pay_mode']
                                                      .toString()
                                                      .toUpperCase())
                                                ],
                                              ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text("Item's Details"),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              // height: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Column(
                                      children: itemsList
                                          .map((e) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          e['item_name']
                                                              .toString(),
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[900],
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        Text(
                                                          e['short_description']
                                                              .toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                        Text(
                                                          "Qty : " +
                                                              e['quantity']
                                                                  .toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .grey[900]),
                                                        ),
                                                      ],
                                                    )),
                                                    Expanded(
                                                        child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          "${map['currency_symbol']} ${e['offer_price']}",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[900],
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        Text(
                                                          "${map['currency_symbol']} ${e['price']}",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .grey[900]),
                                                        ),
                                                      ],
                                                    ))
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                    Divider(
                                      thickness: 0.9,
                                      color: Colors.grey,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Sub Total : ",
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          map['currency_symbol'] +
                                              " " +
                                              map['cust_orderdetails']
                                                      ['sub_total']
                                                  .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Delivery Charges : ",
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          map['currency_symbol'] +
                                              " " +
                                              map['del_disc_fee']
                                                      ['delivery_fee']
                                                  .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Discount : ",
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          map['currency_symbol'] +
                                              " " +
                                              map['del_disc_fee']['discount']
                                                  .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                    Divider(
                                      thickness: 0.9,
                                      color: Colors.grey,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total : ",
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          map['currency_symbol'] +
                                              " " +
                                              map['del_disc_fee']['total']
                                                  .toString(),
                                          style: TextStyle(
                                            color: Colors.grey[900],
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                    map['cust_orderdetails']['invoice']
                                            .toString()
                                            .contains(".pdf")
                                        ? InkWell(
                                            onTap: () {
                                              // showLaoding(context);
                                              // OrdersAPI()
                                              //     .downloadInvoice(
                                              //         widget.m['id'].toString())
                                              //     .then((value) {
                                              //   Navigator.of(context,
                                              //           rootNavigator: true)
                                              //       .pop();
                                              //   _setPath(value);
                                              // });
                                            },
                                            child: Column(
                                              children: [
                                                Divider(
                                                  thickness: 0.9,
                                                  color: Colors.grey,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Invoice Uploaded : ",
                                                      style: TextStyle(
                                                        color: Colors.grey[900],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      style: ButtonStyle(
                                                          padding:
                                                              MaterialStateProperty
                                                                  .all(EdgeInsets
                                                                      .all(0))),
                                                      icon: Icon(
                                                          Icons.attachment),
                                                      label: Text("Download"),
                                                      onPressed: () {},
                                                      // child: Image.asset(
                                                      //   "assets/file.png",
                                                      //   scale: 25,
                                                      //   color: Colors.green,
                                                      // ),
                                                    )
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Invoice Remarks : ",
                                                      style: TextStyle(
                                                        color: Colors.grey[900],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    map['cust_orderdetails'][
                                                                'invoicedetails'] ==
                                                            null
                                                        ? SizedBox()
                                                        : Text(
                                                            map['cust_orderdetails']
                                                                    [
                                                                    'invoicedetails']
                                                                .toString(),
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .grey[900],
                                                              fontSize: 14,
                                                            ),
                                                          )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Customer's Details"),
                                map['userDetail'].length == 0
                                    ? Text(
                                        "N/A",
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            map['userDetail'].length == 0
                                ? SizedBox()
                                : Container(
                                    // height: 200,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          children: [
                                            rows(
                                                "Name",
                                                map['userDetail'][0]['username']
                                                    .toString()),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows(
                                                "Clinic Name",
                                                map['userDetail'][0]
                                                        ['clinic_name']
                                                    .toString()),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows(
                                                "Mobile",
                                                map['userDetail'][0]['mobile']
                                                    .toString()),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows(
                                                "Email Id",
                                                map['userDetail'][0]['email']
                                                    .toString()),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows(
                                                "GSTN No",
                                                map['userDetail'][0]['gstin']
                                                    .toString()),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows("Address",
                                                "${map['userDetail'][0]['address'].toString().toUpperCase()}, ${map['userDetail'][0]['pincode']}"),
                                            SizedBox(
                                              height: 2,
                                            ),
                                            rows(
                                                "Landmark",
                                                map['userDetail'][0]['landmark']
                                                    .toString()),
                                          ],
                                        ))),
                            map['cust_orderdetails']['order_status_name'] ==
                                        "Shipped" ||
                                    map['cust_orderdetails']
                                            ['order_status_name'] ==
                                        "Delivered" ||
                                    map['getPicker'] != null
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Picker's Details"),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text("Assigned",
                                                  style: TextStyle(
                                                      color: Colors.grey[900],
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Image.asset(
                                                "assets/checked.png",
                                                scale: 25,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                rows("Picked By", pickedBy),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Created At",
                                                    map['getPicker']
                                                            ['created_at']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Expired At",
                                                    map['getPicker']
                                                            ['expiry_date']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            map['cust_orderdetails']['order_status_name'] ==
                                        "Shipped" ||
                                    map['cust_orderdetails']
                                            ['order_status_name'] ==
                                        "Delivered"
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Shipping Details"),
                                          map['shipping']['attachment'] == null
                                              ? SizedBox()
                                              : Image.asset(
                                                  "assets/file.png",
                                                  scale: 25,
                                                  color: Colors.green,
                                                )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                          // height: 200,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white),
                                          child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(children: [
                                                rows(
                                                    "Delivery By",
                                                    map['shipping'][
                                                            'delivery_partner_name']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Number",
                                                    map['shipping'][
                                                            'shipping_order_number']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Tracking URL",
                                                    map['shipping']
                                                            ['tracking_url']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Amount",
                                                    map['currency_symbol'] +
                                                        " " +
                                                        map['shipping'][
                                                                'delivery_fee_amount']
                                                            .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Details",
                                                    map['shipping']
                                                            ['shipping_data']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                rows(
                                                    "Date",
                                                    map['shipping']
                                                            ['created_at']
                                                        .toString()),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                              ])))
                                    ],
                                  )
                                : SizedBox()
                          ],
                        ),
                      ),
                    ),
                    map['cust_orderdetails']['order_status_name'] == "Delivered"
                        ? SizedBox()
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                  ),
                                  child: conditionalStatement(),
                                ),
                              ),
                            ),
                          ),
                  ],
                )),
    );
  }

  Widget conditionalStatement() {
    if (map['cust_orderdetails']['order_status_name'].toString() == "New") {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Accept Confirmation"),
                        content: Text("Do you want to accept this order"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                confirmation('2');
                              },
                              child: Text("Confirm"))
                        ],
                      ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/checked.png",
                  scale: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Accept",
                  style: TextStyle(
                      color: Colors.green[900], fontWeight: FontWeight.w800),
                )
              ],
            ),
          )),
          VerticalDivider(
            thickness: 0.9,
            color: Colors.grey,
          ),
          Expanded(
              child: InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text("Reject Confirmation"),
                        content: Text("Do you want to reject this order"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel")),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                confirmation('5');
                              },
                              child: Text("Confirm"))
                        ],
                      ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/cross.png",
                  scale: 20,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Reject",
                  style: TextStyle(
                      color: Colors.red[900], fontWeight: FontWeight.w800),
                )
              ],
            ),
          ))
        ],
      );
    } else if (map['cust_orderdetails']['order_status_name'].toString() ==
            "Accepted" &&
        map['getPicker'] == null) {
      return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: SizedBox(
                        // height: MediaQuery.of(
                        //             context)
                        //         .size
                        //         .height /
                        //     2,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Select Picker",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                RadioGroup<Map>.builder(
                                  textStyle: TextStyle(fontSize: 18),
                                  groupValue: _verticalGroupValue,
                                  onChanged: (value) {
                                    setState(() {
                                      _verticalGroupValue = value!;
                                    });
                                  },
                                  items: _status,
                                  itemBuilder: (item) => RadioButtonBuilder(
                                    item['inventory_name'].toString(),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: Colors.green[800]),
                                          )),
                                      TextButton(
                                          onPressed: () {
                                            showLaoding(context);
                                            OrdersAPI()
                                                .assignPicker(
                                                    widget.m['id'].toString(),
                                                    _verticalGroupValue['id']
                                                        .toString())
                                                .then((value) {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              loaddata();
                                            });
                                          },
                                          child: Text(
                                            "Confirm",
                                            style: TextStyle(
                                                color: Colors.green[800]),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }));
        },
        child: Center(
            child: Text(
          "Select Picker",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        )),
      );
    } else if (map['getPicker'] != null &&
        !map['cust_orderdetails']['invoice'].toString().contains(".pdf")) {
      return InkWell(
        onTap: () async {
          setState(() {
            file.delete();
          });
          TextEditingController textarea = TextEditingController();
          await showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.0))),
              backgroundColor: Colors.white,
              context: context,
              isScrollControlled: true,
              builder: (context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                              InkWell(
                                onTap: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  if (result != null) {
                                    setState(() {
                                      file = File(
                                          result.files.single.path.toString());
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Upload Invoice",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Image.asset(
                                      "assets/upload_2.png",
                                      scale: 20,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              file.existsSync()
                                  ? Column(
                                      children: [
                                        Card(
                                          elevation: 10,
                                          child: ListTile(
                                            leading: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    file.delete();
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                )),
                                            title: Text("Invoice Uploaded"),
                                            trailing: Image.asset(
                                              "assets/file.png",
                                              scale: 20,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: textarea,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 3,
                                  // validator:
                                  //     (value) {
                                  //   if (value == null || value.isEmpty) {
                                  //     return 'Required Field';
                                  //   }
                                  //   return null;
                                  // },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Remarks",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height: 45,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.teal[700])),
                                      onPressed: () {
                                        if (file.existsSync()) {
                                          showLaoding(context);
                                          OrdersAPI()
                                              .uploadInvoice(
                                                  widget.m['id'].toString(),
                                                  file.path.toString(),
                                                  textarea.text.toString())
                                              .then((value) {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .pop();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    content: Text(
                                                        value.toString())));
                                            loaddata();
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Please upload invoice."
                                                    .toString()),
                                            duration: Duration(seconds: 1),
                                          ));
                                        }
                                      },
                                      child: Text(
                                        "Send",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ))),
                            ])));
                  }));
        },
        child: Center(
            child: Text(
          "Upload Invoice",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        )),
      );
    } else if (map['cust_orderdetails']['invoice']
            .toString()
            .contains(".pdf") &&
        map['cust_orderdetails']['order_status_name'] != "Shipped") {
      return InkWell(
        onTap: () async {
          setState(() {
            file.delete();
          });
          TextEditingController deliveryName = TextEditingController();
          TextEditingController shippingNo = TextEditingController();
          TextEditingController trackUrl = TextEditingController();
          TextEditingController fee = TextEditingController();
          TextEditingController shippingDetails = TextEditingController();
          GlobalKey<FormState> form = GlobalKey();
          await showModalBottomSheet(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20.0))),
              backgroundColor: Colors.white,
              context: context,
              isScrollControlled: true,
              builder: (context) => StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                      child: SingleChildScrollView(
                          child: Form(
                        key: form,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();

                                  if (result != null) {
                                    setState(() {
                                      file = File(
                                          result.files.single.path.toString());
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Manual Shipping",
                                        style: GoogleFonts.montserrat(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        )),
                                    Image.asset(
                                      "assets/upload_2.png",
                                      scale: 20,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              file.existsSync()
                                  ? Column(
                                      children: [
                                        Card(
                                          elevation: 10,
                                          child: ListTile(
                                            leading: IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    file.delete();
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                )),
                                            title: Text("Shipping Uploaded"),
                                            trailing: Image.asset(
                                              "assets/file.png",
                                              scale: 20,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                      ],
                                    )
                                  : SizedBox(),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: deliveryName,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required Field';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Delivery Name",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: shippingNo,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required Field';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Shipping Number",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: trackUrl,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required Field';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Tracking URL",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: fee,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required Field';
                                    }
                                    return null;
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Fee",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Color(0xFFEEEEEE))),
                                child: TextFormField(
                                  controller: shippingDetails,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                  maxLines: 3,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required Field';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    contentPadding: EdgeInsets.all(10),
                                    // filled: true,
                                    // fillColor: Colors.teal[50],
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.lightBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    hintText: "Shipping Details",
                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 1.15,
                                  height: 45,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          )),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.teal[700])),
                                      onPressed: () {
                                        if (form.currentState!.validate() &&
                                            file.existsSync()) {
                                          showLaoding(context);
                                          OrdersAPI()
                                              .manualshipping(
                                                  widget.m['id'].toString(),
                                                  file.path.toString(),
                                                  deliveryName.text.toString(),
                                                  shippingNo.text.toString(),
                                                  trackUrl.text.toString(),
                                                  fee.text.toString(),
                                                  shippingDetails.text
                                                      .toString())
                                              .then((value) {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            Navigator.of(context,
                                                    rootNavigator: false)
                                                .pop();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    content: Text(
                                                        value.toString())));
                                            loaddata();
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Please upload shipping."
                                                    .toString()),
                                            duration: Duration(seconds: 1),
                                          ));
                                        }
                                      },
                                      child: Text(
                                        "Send",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color: Colors.white),
                                      ))),
                            ]),
                      )),
                    );
                  }));
        },
        child: Center(
            child: Text(
          "Manual Shipping",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        )),
      );
    } else if (map['cust_orderdetails']['order_status_name'] == "Shipped") {
      return InkWell(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text("Confirmation"),
                    content: Text("Do you want to mark this order complete"),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel")),
                      TextButton(
                          onPressed: () {
                            showLaoding(context);
                            OrdersAPI()
                                .markComplete(widget.m["id"].toString())
                                .then((value) {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.of(context, rootNavigator: false).pop();

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Text(value.toString())));
                              loaddata();
                            });
                          },
                          child: Text("Confirm"))
                    ],
                  ));
        },
        child: Center(
            child: Text(
          "Mark Complete",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        )),
      );
    } else if (map['cust_orderdetails']['order_status_name'] == "Delivered") {
      return SizedBox();
    }
    return SizedBox();
  }

  void confirmation(String id) async {
    showLaoding(context);
    OrdersAPI()
        .orderAcceptorReject(widget.m['id'].toString(), id)
        .then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      loaddata();
      showDialog(
          context: context,
          builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0))),
                child: SizedBox(
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Information",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          value.replaceAll('_', " ").toUpperCase(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "OK",
                                    style: TextStyle(color: Colors.green[800]),
                                  )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ));
    });
  }
}
