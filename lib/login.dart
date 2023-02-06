// ignore_for_file: prefer_const_constructors

import 'package:biz_sales_admin/apis/login_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:biz_sales_admin/UpdateCart.dart';
import 'package:biz_sales_admin/constants.dart';
import 'package:biz_sales_admin/dashboard.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> formkey = GlobalKey();
  TextEditingController emailId = TextEditingController();
  TextEditingController password = TextEditingController();
  bool obstructTextView = true;
  String appVersion = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        // alignment: Alignment.topRight,
        children: [
          // Container(
          //   constraints: BoxConstraints.expand(),
          //   decoration: BoxDecoration(
          //       image: DecorationImage(
          //     alignment: Alignment(0, -1),
          //     // fit: BoxFit.fill,
          //     image: AssetImage(
          //       "assets/bg_img.jpeg",
          //     ),
          //   )),
          // ),
          // Align(
          //   alignment: Alignment.topRight,
          //   child: Padding(
          //     padding: const EdgeInsets.all(15),
          //     child: InkWell(
          //       onTap: () {
          //         Provider.of<UpdateCartData>(context, listen: false)
          //             .showCartorNot();
          //         Navigator.pushAndRemoveUntil(
          //             context,
          //             MaterialPageRoute(builder: (context) => Dashboard()),
          //             (route) => false);
          //       },
          //       child: Container(
          //         decoration: BoxDecoration(
          //             color: Colors.black,
          //             borderRadius: BorderRadius.circular(10)),
          //         child: Padding(
          //           padding: const EdgeInsets.all(5.0),
          //           child: Text(
          //             "Skip Login",
          //             style: TextStyle(fontSize: 12, color: Colors.white),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      )),
      bottomSheet: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
              color: Colors.white70,
              blurRadius: 10.0,
            ),
          ],
          color: Colors.transparent,
        ),
        height: MediaQuery.of(context).size.height / 1.3,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Biz Sales Admin",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 25, fontWeight: FontWeight.w700)),
                SizedBox(
                  height: 20,
                ),
                Text("Log in",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700])),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Required Field";
                        else
                          return null;
                      },
                      controller: emailId,
                      keyboardType: TextInputType.emailAddress,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Email Id*",
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Required Field";
                        else
                          return null;
                      },
                      controller: password,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      obscureText: obstructTextView,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        contentPadding: EdgeInsets.all(10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        hintText: "Password*",
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              obstructTextView = !obstructTextView;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: obstructTextView
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: 45,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green[700])),
                          onPressed: () async {
                            SharedPreferences pref =
                                await SharedPreferences.getInstance();
                            if (formkey.currentState!.validate()) {
                              // ignore: use_build_context_synchronously
                              showLaoding(context);
                              LoginAPI()
                                  .loginApi(emailId.text.toString(),
                                      password.text.toString())
                                  .then((value) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();

                                // setState(() {});
                                pref.setString(
                                    "token", value['token'].toString());
                                pref.setBool("loggedIn", true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            value['Response'].toString())));
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Dashboard()),
                                    (route) => false);
                              });
                            }
                          },
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ))),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "By continuing, you agree to our",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => Policy_View(
                        //             policy: "Term of service".toString(),
                        //             data:
                        //                 "https://idcweb.techstreet.in/#/terms-and-condition"
                        //                     .toString())));
                      },
                      child: Text(
                        "Term of service",
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                    Text(
                      " & ",
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                    InkWell(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => Policy_View(
                        //             policy: "Privacy Policy".toString(),
                        //             data:
                        //                 "https://idcweb.techstreet.in/#/privacy-policy"
                        //                     .toString())));
                      },
                      child: Text(
                        "Privacy Policy",
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text("Ver:" + appVersion)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
