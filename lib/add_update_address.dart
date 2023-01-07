// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddUpdateAddressScreen extends StatefulWidget {
  bool update;
  Map map;
  AddUpdateAddressScreen({required this.update, required this.map});
  @override
  _AddUpdateAddressScreenState createState() => _AddUpdateAddressScreenState();
}

class _AddUpdateAddressScreenState extends State<AddUpdateAddressScreen> {
  GlobalKey<FormState> form = GlobalKey();

  TextEditingController addressType = TextEditingController();
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController doctorName = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.update) {
      // print(widget.map);
      setState(() {
        addressType.text = widget.map['address_type'].toString();
        deliveryAddress.text = widget.map['address'].toString();
        landmark.text = widget.map['landmark'].toString();
        pincode.text = widget.map['pincode'].toString();
        doctorName.text = widget.map['name'].toString();
      });
    } else {
      if (widget.map.isNotEmpty) {
        //  print(widget.map);
        setState(() {
          addressType.text = widget.map['address_type'].toString();
          deliveryAddress.text = widget.map['address'].toString();
          landmark.text = widget.map['landmark'] == null
              ? ""
              : widget.map['landmark'].toString();
          pincode.text = widget.map['pincode'].toString();
          doctorName.text =
              widget.map['name'] == null ? "" : widget.map['name'].toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        title: Text(
          widget.update ? "Update Address" : "New Address",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: addressType,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 15,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Address Type",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: doctorName,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Doctor Name",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  maxLines: 3,
                  controller: deliveryAddress,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Delivery Address",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: landmark,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Landmark",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: pincode,
                  maxLength: 6,
                  onChanged: (val) {
                    if (val.length == 6) {
                      FocusScope.of(context).unfocus();
                    }
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Pincode",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[700])),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String phoneNumber =
                                prefs.getString("userPhoneNo").toString();
                            if (form.currentState!.validate()) {
                              if (widget.update) {
                                Map m = {};
                                m['address_id'] = widget.map['id'].toString();
                                m['name'] = doctorName.text.toString();
                                m['mobile_number'] = phoneNumber;
                                m['pincode'] = pincode.text.toString();
                                m['address'] = deliveryAddress.text.toString();
                                m['landmark'] = landmark.text.toString();
                                m['address_type'] = addressType.text.toString();

                                //print(m);
                                showLaoding(context);

                                LoginAPI().editAddress(m).then((value) async {
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Address Updated Successfully"),
                                          duration: Duration(seconds: 2)),
                                    );
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Update Address Failed"),
                                          duration: Duration(seconds: 2)),
                                    );
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    Navigator.of(context).pop();
                                  }
                                });
                              } else {
                                Map m = {};
                                m['name'] = doctorName.text.toString();
                                m['mobile_number'] = phoneNumber;
                                m['pincode'] = pincode.text.toString();
                                m['address'] = deliveryAddress.text.toString();
                                m['landmark'] = landmark.text.toString();
                                m['address_type'] = addressType.text.toString();
                                m['is_default'] = "1";
                                //print(m);
                                showLaoding(context);

                                LoginAPI().addAddress(m).then((value) async {
                                  if (value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Address Add Successfully"),
                                          duration: Duration(seconds: 2)),
                                    );

                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Add Address Failed"),
                                          duration: Duration(seconds: 2)),
                                    );
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text("Please fill required fields"),
                                    duration: Duration(seconds: 2)),
                              );
                            }
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ))),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
