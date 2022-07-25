// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:instadent/apis/cart_api.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  late String _saveDir;
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void _setPath(String filepath) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("File Downloading...".toString()),
            duration: Duration(seconds: 1)),
      );

      final externalDir = await getExternalStorageDirectory();
      String fileName = DateTime.now().toString() + ".pdf";
      final id = await FlutterDownloader.enqueue(
          url: filepath,
          savedDir: externalDir!.path,
          fileName: fileName,
          showNotification: true,
          openFileFromNotification: true);

      print(id.toString());

      print(externalDir.path + "/" + fileName);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Downloaded - ".toString() + externalDir.path + "/" + fileName),
            duration: Duration(seconds: 3)),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    CartAPI().orderDetails(widget.map['orderId'].toString()).then((value) {
      setState(() {
        isLoading = false;
      });
      if (value.isNotEmpty) {
        setState(() {
          orderMap = value;
          items.addAll(value['items']);
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
              size: 22,
            )),
        elevation: 0,
        leadingWidth: 30,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
          child: SingleChildScrollView(
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
                InkWell(
                  onTap: () {
                    _setPath(widget.map['download_invoice'].toString());
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
                Divider(
                  thickness: 0.9,
                ),
                Text(
                  "13 items in this order",
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
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
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
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey, width: 0.5)),
                                      child: Image.network(
                                        e['product_image'].toString(),
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            "assets/no_image.jpeg",
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
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
                                        Text(e['product_name'].toString()),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "qty - " +
                                                  e['quantity'].toString(),
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                            Text(
                                              "₹" + e['offer_price'].toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                Divider(
                  thickness: 0.9,
                ),
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
                      "₹495",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 18),
                    ),
                  ],
                ),
                Divider(
                  thickness: 0.9,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
