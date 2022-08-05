// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';

class UserProfileViewUpdate extends StatefulWidget {
  @override
  _UserProfileViewUpdateState createState() => _UserProfileViewUpdateState();
}

class _UserProfileViewUpdateState extends State<UserProfileViewUpdate> {
  TextEditingController doctorName = TextEditingController();
  TextEditingController clinicName = TextEditingController();
  TextEditingController gstin = TextEditingController();
  TextEditingController emailId = TextEditingController();
  GlobalKey<FormState> form = GlobalKey();
  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LoginAPI().userProfile().then((value) {
      setState(() {
        doctorName.text = value['username'].toString();
        clinicName.text = value['clinic_name'].toString();
        gstin.text = value['gstin'].toString();
        emailId.text = value['email'].toString();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: backIcon(context),
          elevation: 3,
          title: const Text(
            "Profile",
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
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(children: [
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
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
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
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
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
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
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
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 45,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.green[700])),
                                      onPressed: () {
                                        if (form.currentState!.validate()) {
                                          Map m = {};
                                          m['doctor_name'] =
                                              doctorName.text.toString();
                                          m['clinic_name'] =
                                              clinicName.text.toString();
                                          m['gstin'] = gstin.text.toString();
                                          m['email'] = emailId.text.toString();

                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(
                                          //   SnackBar(
                                          //       content: Text(
                                          //           "Please Wait. Updating Profile."),
                                          //       duration: Duration(seconds: 2)),
                                          // );
                                          showLaoding(context);

                                          LoginAPI()
                                              .profileUpdate(m)
                                              .then((value) async {
                                            if (value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Profile Updated."),
                                                    duration:
                                                        Duration(seconds: 2)),
                                              );
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              Navigator.of(context).pop();
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "Profile Updatation Failed."),
                                                    duration:
                                                        Duration(seconds: 2)),
                                              );
                                            }
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
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
                            ),
                          ])))));
  }
}
