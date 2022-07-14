// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/otp.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginPhone = TextEditingController();

  void getPhoneNumber() async {
    SmsAutoFill _autoFill = SmsAutoFill();
    var completePhoneNumber = _autoFill.hint;
    completePhoneNumber.then((value) {
      if (value != null) {
        setState(() {
          loginPhone.text = value.toString().substring(3);
        });
      }
    });
  }

  @override
  void dispose() {
    SmsAutoFill();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoneNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
              alignment: Alignment(0, -1),
              // fit: BoxFit.fill,
              image: AssetImage(
                "assets/bg_img.jpeg",
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: InkWell(
              onTap: () {
                Provider.of<UpdateCartData>(context, listen: false)
                    .showCartorNot();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Dashboard()),
                    (route) => false);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    "Skip Login",
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
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
        height: MediaQuery.of(context).size.height / 2.3,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
              ),
              Text("Same Day Delivery",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      fontSize: 25, fontWeight: FontWeight.w700)),
              SizedBox(
                height: 20,
              ),
              Text("Log in or sign up",
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
                    // onTap: () {
                    //   getPhoneNumber();
                    // },
                    onChanged: (value) {
                      if (value.length == 10) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    controller: loginPhone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.all(2),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      hintText: "Enter mobile number",
                      hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          "+91",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
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
                        onPressed: () {
                          if (loginPhone.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Enter mobile number".toString()),
                                  duration: Duration(seconds: 1)),
                            );
                          } else if (loginPhone.text.length != 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Enter 10 digit mobile number"
                                      .toString()),
                                  duration: Duration(seconds: 1)),
                            );
                          } else {
                            showLaoding(context);

                            LoginAPI()
                                .userLogin(loginPhone.text.toString())
                                .then((value) {
                              if (value['ErrorCode'] == 100) {
                                print(value);
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("OTP Sent".toString()),
                                      duration: Duration(seconds: 1)),
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => OTPScreen(
                                            phoneNumber:
                                                loginPhone.text.toString())));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          value['ErrorMessage'].toString()),
                                      duration: Duration(seconds: 1)),
                                );
                              }
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
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {},
                    child: Text(
                      "Term of service",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
