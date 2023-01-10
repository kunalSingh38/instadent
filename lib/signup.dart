// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  bool signupNew = false;

  String phoneNumber;
  SignUpScreen({required this.phoneNumber, required this.signupNew});
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();
  TextEditingController doctorName = TextEditingController();
  TextEditingController clinicName = TextEditingController();
  TextEditingController gstin = TextEditingController();
  TextEditingController emailId = TextEditingController();
  TextEditingController deliveryAddress = TextEditingController();
  TextEditingController landmark = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController registrationNumber = TextEditingController();
  TextEditingController primaryWhatsAppNumber = TextEditingController();
  TextEditingController secondaryWhatsAppNumber = TextEditingController();
  TextEditingController assistantNumber = TextEditingController();
  bool sameNumberSaved = true;

  List registrationTypeList = ["Male", "Female", "Other"];
  String registrationTypeValue = "Male";

  GlobalKey<FormState> form = GlobalKey();
  String profileImagePath = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      primaryWhatsAppNumber.text = widget.phoneNumber.toString();
    });

    if (!widget.signupNew) {
      setState(() {
        isLoading = true;
      });
      LoginAPI().userProfile().then((value) {
        setState(() {
          isLoading = false;
        });
        setState(() {
          doctorName.clear();
          clinicName.clear();
          gstin.clear();
          emailId.clear();
          registrationNumber.clear();
          sameNumberSaved = true;
          secondaryWhatsAppNumber.clear();
          assistantNumber.clear();
          deliveryAddress.clear();
          landmark.clear();
          pincode.clear();

          doctorName.text = value['username'].toString();
          clinicName.text = value['clinic_name'].toString();
          gstin.text = value['gstin'] == null ? "" : value['gstin'].toString();
          emailId.text = value['email'].toString();
          registrationNumber.text = value['registration_no'] == null
              ? ""
              : value['registration_no'].toString();
          sameNumberSaved =
              value['is_whatsapp_alternate'].toString() == "1" ? false : true;
          log("--->${value['is_whatsapp_alternate'].toString()}");
          secondaryWhatsAppNumber.text =
              value['alternate_whatsapp_number'] == null
                  ? ""
                  : value['alternate_whatsapp_number'].toString();
          assistantNumber.text = value['assistant_phone_no'] == null
              ? ""
              : value['assistant_phone_no'].toString();
          registrationTypeValue = value['gender'] == "male" ? "Male" : "Female";
        });
      });
      // setState(() {
      //   doctorName.
      //   clinicName.clear();
      //   gstin.clear();
      //   emailId.clear();
      //   registrationNumber.clear();
      //   sameNumberSaved = true;
      //   secondaryWhatsAppNumber.clear();
      //   assistantNumber.clear();
      //   deliveryAddress.clear();
      //   landmark.clear();
      //   pincode.clear();
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: backIcon(context),
          elevation: 3,
          actions: [
            widget.signupNew
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        doctorName.clear();
                        clinicName.clear();
                        gstin.clear();
                        emailId.clear();
                        registrationNumber.clear();
                        sameNumberSaved = true;
                        secondaryWhatsAppNumber.clear();
                        assistantNumber.clear();
                        deliveryAddress.clear();
                        landmark.clear();
                        pincode.clear();
                      });
                    },
                    child: Text("Clear"))
                : SizedBox()
          ],
          title: Text(
            widget.signupNew ? "Sign Up" : "Profile",
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
          ),
        ),
        body: widget.signupNew
            ? formBody()
            : isLoading
                ? loadingProducts("Please Wait. Fetching your details.")
                : formBody());
  }

  Widget formBody() => Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                // Stack(
                //   children: [
                //     Center(
                //       child: CircleAvatar(
                //         radius: 71,
                //         backgroundColor: Colors.blue[800],
                //         child: CircleAvatar(
                //           radius: 70,
                //           backgroundColor: Colors.white,
                //           backgroundImage:
                //               AssetImage("assets/profile_photo.png"),
                //         ),
                //       ),
                //     ),
                //     Positioned(
                //       bottom: 0,
                //       right: 80,
                //       child: InkWell(
                //         onTap: () {
                //           showPhotoCaptureOptions();
                //         },
                //         child: Image.asset(
                //           "assets/upload.png",
                //           scale: 10,
                //         ),
                //       ),
                //     )
                //   ],
                // ),
                // SizedBox(
                //   height: 30,
                // ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: doctorName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Doctor Name*",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          value: registrationTypeValue,
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              registrationTypeValue = newValue.toString();
                            });
                          },
                          items: registrationTypeList.map((value) {
                            return DropdownMenuItem(
                                value: value,
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ));
                          }).toList(),
                        ),
                      ),
                    );
                  },
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
                  controller: clinicName,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Clinic Name*",
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
                    labelText: "Email Id*",
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
                  // validator: (value) {
                  //   if (value!.isEmpty)
                  //     return "Required Field";
                  //   else
                  //     return null;
                  // },
                  controller: registrationNumber,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Dental Council Registration Number",
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
                  controller: primaryWhatsAppNumber,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  readOnly: true,
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Primary Contact Number*",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),

                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green[100]),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 10,
                                child: Text(
                                  "I use this number on whatsApp.",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                )),
                            Expanded(
                                child: Checkbox(
                                    value: sameNumberSaved,
                                    onChanged: (val) {
                                      setState(() {
                                        sameNumberSaved = !sameNumberSaved;
                                      });
                                    }))
                          ],
                        )),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),

                sameNumberSaved
                    ? SizedBox()
                    : Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Required Field";
                              else
                                return null;
                            },
                            controller: secondaryWhatsAppNumber,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              counterText: "",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(10),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: "WhatsApp Contact Number*",
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                TextFormField(
                  // validator: (value) {
                  //   if (value!.isEmpty)
                  //     return "Required Field";
                  //   else
                  //     return null;
                  // },
                  controller: assistantNumber,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    counterText: "",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Assistant Contact Number",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                widget.signupNew
                    ? Column(
                        children: [
                          TextFormField(
                              validator: (value) {
                                if (value!.isEmpty)
                                  return "Required Field";
                                else
                                  return null;
                              },
                              maxLines: 3,
                              controller: deliveryAddress,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  contentPadding: EdgeInsets.all(10),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10)),
                                  labelText: "Delivery Address*",
                                  labelStyle: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300),
                                  suffixIcon: InkWell(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
                                      showLaoding(context);
                                      _determinePosition().then((value) {
                                        _getAddress(value);
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/gps2.png",
                                      scale: 20,
                                    ),
                                  ))),
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
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(10),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: "Landmark*",
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
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              contentPadding: EdgeInsets.all(10),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: "Pincode*",
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),

                SizedBox(height: 20),
                widget.signupNew
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green[700])),
                                onPressed: () {
                                  if (form.currentState!.validate()) {
                                    Map m = {};
                                    m['doctor_name'] =
                                        doctorName.text.toString();
                                    m['clinic_name'] =
                                        clinicName.text.toString();
                                    m['phone'] = widget.phoneNumber.toString();
                                    m['gstin'] = gstin.text.toString();
                                    m['address'] =
                                        deliveryAddress.text.toString();
                                    m['pincode'] = pincode.text.toString();
                                    m['landmark'] = landmark.text.toString();
                                    m['email'] = emailId.text.toString();
                                    m['registration_no'] =
                                        registrationNumber.text.toString();
                                    m['gender'] = registrationTypeValue
                                        .toLowerCase()
                                        .toString();
                                    m['assistant_phone_no'] =
                                        assistantNumber.text.toString();
                                    m['is_whatsapp_alternate'] =
                                        sameNumberSaved ? "0" : "1";
                                    m['alternate_whatsapp_number'] =
                                        sameNumberSaved
                                            ? ""
                                            : secondaryWhatsAppNumber.text
                                                .toString();

                                    m.forEach((key, value) {
                                      print(key + ":" + value);
                                    });
                                    showLaoding(context);

                                    LoginAPI()
                                        .registration(m)
                                        .then((value) async {
                                      Navigator.of(context).pop();
                                      if (value["ErrorCode"] == 0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  "Registration Successfully"),
                                              duration: Duration(seconds: 2)),
                                        );
                                        SharedPreferences pref =
                                            await SharedPreferences
                                                .getInstance();
                                        pref.setBool("loggedIn", true);
                                        pref.setString(
                                            "userPhoneNo",
                                            value["Response"]["mobile"]
                                                .toString());
                                        pref.setString(
                                            "token", value["token"].toString());
                                        Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Dashboard()),
                                            (route) => false);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text("Registration Failed"),
                                              duration: Duration(seconds: 2)),
                                        );
                                      }
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Please fill required fields"),
                                          duration: Duration(seconds: 2)),
                                    );
                                  }
                                },
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ))),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.green[700])),
                                onPressed: () {
                                  if (form.currentState!.validate()) {
                                    Map m = {};
                                    m['doctor_name'] =
                                        doctorName.text.toString();
                                    m['clinic_name'] =
                                        clinicName.text.toString();
                                    // m['phone'] = widget.phoneNumber.toString();
                                    m['gstin'] = gstin.text.toString();
                                    // m['address'] =
                                    //     deliveryAddress.text.toString();
                                    // m['pincode'] = pincode.text.toString();
                                    // m['landmark'] = landmark.text.toString();
                                    m['email'] = emailId.text.toString();
                                    m['registration_no'] =
                                        registrationNumber.text.toString();
                                    m['gender'] = registrationTypeValue
                                        .toLowerCase()
                                        .toString();
                                    m['assistant_phone_no'] =
                                        assistantNumber.text.toString();
                                    m['is_whatsapp_alternate'] =
                                        sameNumberSaved ? "0" : "1";
                                    m['alternate_whatsapp_number'] =
                                        sameNumberSaved
                                            ? ""
                                            : secondaryWhatsAppNumber.text
                                                .toString();
                                    print(jsonEncode(m));
                                    showLaoding(context);

                                    LoginAPI()
                                        .profileUpdate(m)
                                        .then((value) async {
                                      Navigator.of(context).pop();
                                      if (value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text("Profile Updated"),
                                              duration: Duration(seconds: 2)),
                                        );
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text("Profile Update Failed"),
                                              duration: Duration(seconds: 2)),
                                        );
                                      }
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Please fill required fields"),
                                          duration: Duration(seconds: 2)),
                                    );
                                  }
                                },
                                child: Text(
                                  "Update Profile",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                                ))),
                      ),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  height: 40,
                ),
                InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.0))),
                        backgroundColor: Colors.white,
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                            child: SingleChildScrollView(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  Image.asset(
                                    "assets/warning.png",
                                    scale: 8,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text("Sad To See You Go",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                      "You will lose your past order details. Would you still like to proceed?",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 45,
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.white),
                                                      side:
                                                          MaterialStateProperty
                                                              .all(BorderSide(
                                                                  color: Colors
                                                                      .grey))),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    "No, Thank You",
                                                    style: TextStyle(
                                                        color: Colors.pink,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16),
                                                  ))),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 45,
                                              child: ElevatedButton(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.pink)),
                                                  onPressed: () {
                                                    OtherAPI()
                                                        .deleteAccount()
                                                        .then((value) async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      if (value) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  "Account Deleted."),
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2)),
                                                        );

                                                        SharedPreferences
                                                            prefs =
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
                                                                  (route) =>
                                                                      false);
                                                        });
                                                        Provider.of<UpdateCartData>(
                                                                context,
                                                                listen: false)
                                                            .showCartorNot();
                                                      }
                                                    });
                                                  },
                                                  child: Text(
                                                    "Continue",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16),
                                                  ))),
                                        ),
                                      )
                                    ],
                                  )
                                ]))));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Delete Account",
                        style: TextStyle(
                            color: Colors.red[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Deleting your account will remove all your orders.",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

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
                                maxHeight: 1000,
                                maxWidth: 1200,
                                imageQuality: 100);
                            if (result != null) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Upload profile picture"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                OtherAPI().profilePhotoUpload(
                                                    result.path.toString());
                                              },
                                              child: Text("Upload"))
                                        ],
                                      ));
                            }
                            // Navigator.of(context).pop();
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
                                maxHeight: 1000,
                                maxWidth: 1200,
                                imageQuality: 100);
                            if (result != null) {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text("Confirmation"),
                                        content: Text("Upload profile picture"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Cancel")),
                                          TextButton(
                                              onPressed: () {
                                                OtherAPI().profilePhotoUpload(
                                                    result.path.toString());
                                              },
                                              child: Text("Upload"))
                                        ],
                                      ));
                            }
                            // Navigator.of(context).pop();
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getAddress(value) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    Placemark place = placemarks[0];
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      Navigator.of(context).pop();
    });
    setState(() {
      deliveryAddress.clear();
      deliveryAddress.text = place.subAdministrativeArea.toString() +
          " ," +
          place.name.toString() +
          " ," +
          place.subLocality.toString() +
          " ," +
          place.locality.toString() +
          " ," +
          place.postalCode.toString() +
          " ," +
          place.country.toString();
      pincode.clear();
      pincode.text = place.postalCode.toString();
    });
  }
}
