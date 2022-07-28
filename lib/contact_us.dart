// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instadent/apis/other_api.dart';
import 'package:instadent/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  GlobalKey<FormState> form = GlobalKey();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController subject = TextEditingController();
  TextEditingController content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: backIcon(context),
        elevation: 3,
        leadingWidth: 30,
        title: const Text(
          "Contact Us",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
        actions: [
          InkWell(
            onTap: () async {
              await launch("https://wa.me/919899339093");
            },
            child: Image.asset(
              "assets/whatsapp.png",
              scale: 20,
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Contact Details",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/email.png",
                        scale: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 10,
                      child: Text(
                        "contact@instadent.in",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        "assets/placeholder.png",
                        scale: 20,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 10,
                      child: Text(
                        "Khasra no. 714, near Geetanjali salon, Rajpur Khurd Extension, Chhatarpur, New Delhi, Delhi 110074",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontSize: 16),
                      ),
                    )
                  ],
                ),
                Divider(
                  thickness: 0.9,
                  color: Colors.grey,
                  height: 40,
                ),
                Text(
                  "For any query please fill the below form.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: name,

                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Name",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: email,

                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Email",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: phone,
                  maxLength: 10,
                  onChanged: (val) {
                    if (val.length == 10) {
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
                    labelText: "Phone",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: subject,

                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Subject",
                    counterText: "",
                    labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLines: 4,
                  validator: (value) {
                    if (value!.isEmpty)
                      return "Required Field";
                    else
                      return null;
                  },
                  controller: content,

                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  // keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10)),
                    labelText: "Content",
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
                          if (form.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Adding submission"),
                              ),
                            );
                            OtherAPI()
                                .contactUs(
                                    name.text.toString(),
                                    email.text.toString(),
                                    phone.text.toString(),
                                    subject.text.toString(),
                                    content.text.toString())
                                .then((value) {
                              if (value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Submission successful"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Submission Failed"),
                                  ),
                                );
                                Navigator.of(context).pop();
                              }
                            });
                          }
                        },
                        child: Text(
                          "Send",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white),
                        ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
