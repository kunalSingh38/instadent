// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/cart/return_order_details.dart';
import 'package:instadent/cart/review_rating.dart';
import 'package:instadent/constants.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummaryScreen extends StatefulWidget {
  Map map = {};
  OrderSummaryScreen({required this.map});

  @override
  _OrderSummaryScreenState createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  Map orderMap = {};
  bool isLoading = true;
  List items = [];
  ReceivePort _port = ReceivePort();
  String orderId = "";
  String payment = "";
  String orderPlaced = "";
  String trackLink = "";
  String total = "";
  bool isDelivered = false;
  TextStyle style1 = TextStyle(
      fontWeight: FontWeight.w400, fontSize: 16, color: Colors.grey[600]);
  TextStyle style2 =
      TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black);
  // @override
  // void dispose() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  //   super.dispose();
  // }

  // late String _saveDir;
  // static void downloadCallback(
  //     String id, DownloadTaskStatus status, int progress) {
  //   final SendPort? send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port');
  //   send!.send([id, status, progress]);
  // }

  // void _setPath(String filepath) async {
  //   bool permissionAccess = false;
  //   if (await Permission.storage.request().isGranted) {
  //     setState(() {
  //       permissionAccess = true;
  //     });
  //   }
  //   if (await Permission.manageExternalStorage.request().isGranted) {
  //     setState(() {
  //       permissionAccess = true;
  //     });
  //   }

  //   if (permissionAccess) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text("File Downloading...".toString()),
  //           duration: Duration(seconds: 1)),
  //     );

  //     final externalDir = await getExternalStorageDirectory();
  //     String fileName = DateTime.now().toString() + ".pdf";
  //     final id = await FlutterDownloader.enqueue(
  //         url: filepath,
  //         savedDir: externalDir!.path,
  //         fileName: fileName,
  //         showNotification: true,
  //         openFileFromNotification: true);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text(
  //               "Downloaded - ".toString() + externalDir.path + "/" + fileName),
  //           duration: Duration(seconds: 3)),
  //     );
  //   }
  // }

  bool isLoading2 = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.map['orderId'].toString());
    CartAPI().orderDetails(widget.map['orderId'].toString()).then((value) {
      setState(() {
        isLoading = false;
      });

      if (value.isNotEmpty) {
        setState(() {
          orderMap = value;
          items.addAll(value['items']);
          orderId = value['order_number'].toString();
          orderPlaced = value['created_at'].toString();
          payment = value['payment_mode'].toString();
          trackLink = widget.map['liveTrackLink'].toString();
          total = value['total'].toString();
          isDelivered = value['order_status'] == "Delivered" ? true : false;
        });
      }
    });

    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, 'downloader_send_port');
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data[1];
    //   int progress = data[2];
    //   setState(() {});
    // });

    // FlutterDownloader.registerCallback(downloadCallback);
  }

  TextEditingController controller = TextEditingController();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: isLoading2
            ? PreferredSize(
                preferredSize: Size(double.infinity, 1.0),
                child: LinearProgressIndicator(),
              )
            : null,
        backgroundColor: Colors.grey[50],
        leading: backIcon(context),
        elevation: 0,
      ),
      body: isLoading
          ? loadingProducts("Please wait. Collecting order details.")
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order summary",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 25),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Arrived at 08:46 am",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                              fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widget.map['download_invoice'] == null
                                ? SizedBox()
                                : InkWell(
                                    onTap: () async {
                                      String filePath = widget
                                          .map['download_invoice']
                                          .toString();
                                      // _setPath(
                                      //     widget.map['download_invoice'].toString());
                                      if (await Permission.storage
                                          .request()
                                          .isGranted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                "Downloading...".toString()),
                                          ),
                                        );
                                        String path = "";
                                        if (Platform.isAndroid) {
                                          final baseStorage =
                                              await getExternalStorageDirectory();
                                          path = baseStorage!.path.toString();
                                        } else {
                                          final baseStorage =
                                              await getApplicationDocumentsDirectory();
                                          path = baseStorage.path;
                                        }

                                        print(path);
                                        print(filePath);
                                        // Dio dio = Dio();
                                        // var response = await dio.download(filePath,
                                        //     path + '/' + filePath.split(".com/")[1]);
                                        // print(response.statusMessage);
                                        // print(response.statusCode);

                                        // if (response.statusCode == 200) {
                                        //   ScaffoldMessenger.of(context)
                                        //       .hideCurrentSnackBar();
                                        //   ScaffoldMessenger.of(context).showSnackBar(
                                        //     SnackBar(
                                        //       content: Text(
                                        //           "Download at ".toString() +
                                        //               filePath.toString()),
                                        //     ),
                                        //   );
                                        // }
                                        // if (Platform.isIOS) {
                                        //   OpenFile.open(
                                        //       '$path/' + filePath.split(".com/")[1]);
                                        // }
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Text("Download summary",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green[700],
                                                fontSize: 14)),
                                        Icon(
                                          Icons.file_download_outlined,
                                          color: Colors.green[700],
                                          size: 20,
                                        )
                                      ],
                                    ),
                                  ),
                            isDelivered
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ReturnOrderDetailsScreen(
                                                      m: orderMap)));
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "Return & Replacment",
                                          style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.green[700],
                                          size: 14,
                                        )
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        cancelReason.clear();
                                      });
                                      suggestCancelReason(orderId);
                                    },
                                    child: Text(
                                      "Cancel Order",
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                  )
                          ],
                        ),
                        Divider(
                          thickness: 0.9,
                        ),
                        Text(
                          items.length.toString() + " items in this order",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: items
                              .map((e) => InkWell(
                                    onTap: () {
                                      setState(() {
                                        isLoading2 = true;
                                      });
                                      OtherAPI()
                                          .singleProductDetails(
                                              e['id'].toString())
                                          .then((value) async {
                                        setState(() {
                                          isLoading2 = false;
                                        });
                                        await showProdcutDetails(
                                            context,
                                            value,
                                            false,
                                            controller,
                                            [],
                                            dynamicLinks,
                                            true);
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 0.5)),
                                                child: Image.network(
                                                  e['product_image'].toString(),
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      "assets/no_image.jpeg",
                                                    );
                                                  },
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
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
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 6,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SelectableText(
                                                      e['product_name']
                                                          .toString()),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "qty - " +
                                                            e['quantity']
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      Text(
                                                        "₹" +
                                                            e['offer_price']
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 10,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bill Details",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "MRP",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 14),
                            ),
                            Text(
                              "₹171",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Product Discount",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 14),
                            ),
                            Text(
                              "-₹35",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery charges",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 14),
                            ),
                            Text(
                              "+₹15",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Bill Total",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 18),
                            ),
                            Text(
                              "₹" + total.toString(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 10,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order details",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Order id", style: style1),
                        SizedBox(
                          height: 10,
                        ),
                        SelectableText(orderId.toString().toUpperCase(),
                            style: style2),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Payment", style: style1),
                        SizedBox(
                          height: 10,
                        ),
                        Text(payment.toString(), style: style2),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Deliver to", style: style1),
                        SizedBox(
                          height: 10,
                        ),
                        Text("-"),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Order placed", style: style1),
                        SizedBox(
                          height: 10,
                        ),
                        Text(DateFormat.yMMMMd("en_US")
                            .add_jm()
                            .format(DateTime.parse(orderPlaced))),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 10,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 5, 80),
                    child: InkWell(
                      onTap: () async {
                        await launch("https://wa.me/" + whatsAppNo);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Image.asset("assets/call.png"),
                              title: Text(
                                "Need help with your order?",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Support is always available",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              )),
                          ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                  "assets/chat.png",
                                  scale: 15,
                                ),
                              ),
                              title: Text(
                                "Chat with a support executive",
                                style: TextStyle(
                                    color: Colors.green[800],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "About any issues related to your order",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
      bottomSheet: isDelivered
          ? Container(
              height: 70,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  ),
                ],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 45,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.teal[700])),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewAndRating(
                                        orderId: orderId,
                                      )));
                          // reviewAndRating(orderId);
                        },
                        child: Text(
                          "Review and Rating",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white),
                        ))),
              ),
            )
          : trackLink.isEmpty
              ? SizedBox()
              : Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                                backgroundColor: MaterialStateProperty.all(
                                    trackLink.isEmpty
                                        ? Colors.grey
                                        : Colors.teal[700])),
                            onPressed: () {
                              launchUrl(Uri.parse(trackLink.toString()));
                            },
                            child: Text(
                              "track your order",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white),
                            ))),
                  ),
                ),
    );
  }

  TextEditingController cancelReason = TextEditingController();
  Future<void> suggestCancelReason(String orderId) async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Text("Why do you want to cancel the order?",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Color(0xFFEEEEEE))),
                    child: TextFormField(
                      // autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      controller: cancelReason,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      maxLines: 6,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.white,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Enter your reason",
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
                      width: MediaQuery.of(context).size.width / 1.15,
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.teal[700])),
                          onPressed: () {
                            if (cancelReason.text.isNotEmpty) {
                              CartAPI()
                                  .cancelOrder(orderId.toString(),
                                      cancelReason.text.toString())
                                  .then((value) {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                if (value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Order Cancelled".toString()),
                                        duration: Duration(seconds: 1)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Order cancellation failed"
                                                .toString()),
                                        duration: Duration(seconds: 1)),
                                  );
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Please enter cancel reason."
                                        .toString()),
                                    duration: Duration(seconds: 1)),
                              );
                            }
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                color: Colors.white),
                          ))),
                ]))));
  }
}
