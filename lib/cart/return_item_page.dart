// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instadent/account.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReturnItemScreen extends StatefulWidget {
  Map m = {};
  int index = 0;
  ReturnItemScreen({required this.m, required this.index});

  @override
  _ReturnItemScreenState createState() => _ReturnItemScreenState();
}

class _ReturnItemScreenState extends State<ReturnItemScreen> {
  final ImagePicker _picker = ImagePicker();
  TextStyle textStyle1 = TextStyle(color: Colors.black);
  int max = 0;

  List<String> returnQuestions = [];
  String verticalGroupValue = "";
  String refundType = "";
  String question = "";
  bool isLoading = true;
  List uploadImage = ["assets/more.png"];
  int qunantity = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      max = int.parse(widget.m['items'][widget.index]['quantity'].toString());
      qunantity =
          int.parse(widget.m['items'][widget.index]['quantity'].toString());
    });

    OtherAPI().getRequestQuestion().then((value) {
      if (value["ErrorCode"] == 0) {
        setState(() {
          question = value['Response'][0]['question'].toString();
          returnQuestions.clear();

          List temp = value['Response'][0]['question_option'];
          temp.forEach((element) {
            returnQuestions.add(element['question'].toString());
          });
        });
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: backIcon(context),
          elevation: 3,
          title: const Text(
            "Return & Refund",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: Colors.grey, width: 0.5)),
                          child: Image.network(
                            widget.m['items'][widget.index]['product_image']
                                .toString(),
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/no_image.jpeg",
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SelectableText(widget.m['items'][widget.index]
                                    ['product_name']
                                .toString()),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Qty - " +
                                  max.toString() +
                                  "  ₹" +
                                  widget.m['items'][widget.index]['offer_price']
                                      .toString(),
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Please Select the Quantity to place Return/Replacement.",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        width: 75,
                        height: 28,
                        decoration: BoxDecoration(
                            color: Colors.teal[100],
                            border: Border.all(color: Color(0xFF004D40)),
                            borderRadius: BorderRadius.circular(10)),
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 4, 2, 4),
                                  child: Text(
                                    "-",
                                    style: textStyle1,
                                  ),
                                ),
                                Text(
                                  qunantity.toString(),
                                  style: textStyle1,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 4, 8, 4),
                                  child: Text(
                                    "+",
                                    style: textStyle1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: InkWell(
                                  onTap: () async {
                                    if (qunantity > 1) {
                                      setState(() {
                                        qunantity = qunantity - 1;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Can't reduce less than 1"
                                                    .toString()),
                                            duration:
                                                Duration(milliseconds: 700)),
                                      );
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                )),
                                Expanded(
                                    child: InkWell(
                                  onTap: () async {
                                    if (qunantity < max) {
                                      setState(() {
                                        qunantity = qunantity + 1;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Can't add more than " +
                                                    max.toString()),
                                            duration:
                                                Duration(milliseconds: 700)),
                                      );
                                    }
                                  },
                                  child: Container(color: Colors.transparent),
                                ))
                              ],
                            )
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  question.toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: returnQuestions
                      .map((e) => InkWell(
                            onTap: () {
                              setState(() {
                                verticalGroupValue = e.toString();
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    width: 20,
                                    child: Radio(
                                        value: e.toString(),
                                        groupValue: verticalGroupValue,
                                        onChanged: (val) {
                                          setState(() {
                                            verticalGroupValue = val.toString();
                                          });
                                        }),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Text(e.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                          fontSize: 14)),
                                )
                              ],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Select an action",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                RadioGroup<String>.builder(
                  groupValue: refundType,
                  onChanged: (value) => setState(() {
                    refundType = value.toString();
                  }),
                  items: ["Initiate Return", "Initiate Replacement"],
                  itemBuilder: (item) => RadioButtonBuilder(item),
                  direction: Axis.horizontal,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Upload max 5 images",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 14),
                ),
                SizedBox(
                  height: 10,
                ),
                GridView.count(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  // childAspectRatio: 1.1,
                  children: uploadImage
                      .map((e) => uploadImage.indexOf(e) == 0
                          ? Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5)),
                              child: InkWell(
                                onTap: () {
                                  if (uploadImage.length < 6) {
                                    showPhotoCaptureOptions();
                                  }
                                },
                                child: Image.asset(
                                  e.toString(),
                                  scale: 10,
                                ),
                              ))
                          : Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Center(
                                    child: Image.file(
                                      File(e.toString()),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          uploadImage
                                              .removeAt(uploadImage.indexOf(e));
                                        });
                                      },
                                      child: Image.asset(
                                        "assets/clear.png",
                                        scale: 30,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                      .toList(),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
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
                          if (verticalGroupValue.toString() == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please select return reason."
                                      .toString()),
                                  duration: Duration(milliseconds: 700)),
                            );
                          } else if (refundType.toString() == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Please select return or replacement."
                                          .toString()),
                                  duration: Duration(milliseconds: 700)),
                            );
                          } else if (uploadImage.length == 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Please upload alteast 1 image"
                                      .toString()),
                                  duration: Duration(milliseconds: 700)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Please confirm you request".toString()),
                                  duration: Duration(seconds: 1),
                                  action: SnackBarAction(
                                      label: "Confirm",
                                      onPressed: () {
                                        uploadImage.removeAt(0);
                                        Map m = {};

                                        for (var element in uploadImage) {
                                          m['image' +
                                              (uploadImage.indexOf(element) + 1)
                                                  .toString()] = element
                                              .toString();
                                        }

                                        m['order_id'] =
                                            widget.m['id'].toString();
                                        m['quantity'] = qunantity.toString();
                                        m['return_type'] =
                                            refundType == "Initiate Return"
                                                ? "1"
                                                : "2";
                                        m['reason'] =
                                            verticalGroupValue.toString();
                                        m['item_id'] = widget.m['items']
                                                [widget.index]['id']
                                            .toString();

                                        m['question_response'] = "";
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Returning Products..."
                                                      .toString()),
                                              duration: Duration(seconds: 1)),
                                        );
                                        OtherAPI()
                                            .startReturnProduct(m)
                                            .then((value) {
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   SnackBar(
                                          //       content: Text(value),
                                          //       duration: Duration(seconds: 2)),
                                          // );
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text("Message"),
                                                    content:
                                                        Text(value.toString()),
                                                  ));
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        });
                                      })),
                            );
                          }
                        },
                        child: Text(
                          "Confirm",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white),
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showPhotoCaptureOptions() async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0))),
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
                    child: Text(
                      'Select',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? result = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );

                            if (result != null) {
                              setState(() {
                                uploadImage.add(result.path.toString());
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: Icon(
                            Icons.camera,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Camera",
                            style: TextStyle(color: Colors.black),
                          )),
                      SizedBox(
                        width: 30,
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            final XFile? result = await _picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxHeight: 480,
                              maxWidth: 640,
                            );

                            if (result != null) {
                              setState(() {
                                uploadImage.add(result.path.toString());
                              });
                            }
                            Navigator.of(context).pop();
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.grey)))),
                          icon: Icon(
                            Icons.photo,
                            color: Colors.black,
                          ),
                          label: Text(
                            "Gallery",
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  )
                ])));
  }
}
