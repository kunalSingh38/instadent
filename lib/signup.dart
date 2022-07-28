// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  String phoneNumber;
  SignUpScreen({required this.phoneNumber});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController doctorName = TextEditingController();
  TextEditingController clinicName = TextEditingController();
  TextEditingController gstin = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController pincode = TextEditingController();

  GlobalKey<FormState> form = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        leadingWidth: 30,
        title: const Text(
          "Sign Up",
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
                  controller: clinicName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Clinic Name",
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
                  controller: gstin,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "GSTIN",
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
                  controller: emailId,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Email Id",
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
                  controller: deliveryAddress,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                          onPressed: () {
                            if (form.currentState!.validate()) {
                              Map m = {};
                              m['doctor_name'] = doctorName.text.toString();
                              m['clinic_name'] = clinicName.text.toString();
                              m['gstin'] = gstin.text.toString();
                              m['address'] = deliveryAddress.text.toString();
                              m['pincode'] = pincode.text.toString();
                              m['landmark'] = landmark.text.toString();
                              m['email'] = emailId.text.toString();
                              m['phone'] = widget.phoneNumber.toString();

                              showLaoding(context);

                              LoginAPI().registration(m).then((value) async {
                                Navigator.of(context).pop();
                                if (value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Registration Successfully"),
                                        duration: Duration(seconds: 2)),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Registration Failed"),
                                        duration: Duration(seconds: 2)),
                                  );
                                }
                              });
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
