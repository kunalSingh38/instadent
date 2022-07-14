// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:instadent/apis/login_api.dart';
import 'package:instadent/constants.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/signup.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  String phoneNumber;
  OTPScreen({required this.phoneNumber});
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late OTPTextEditController controller;
  late OTPInteractor _otpInteractor;

  TextEditingController otpControll = TextEditingController();

  void listenSMS() async {
    _otpInteractor = OTPInteractor();
    _otpInteractor
        .getAppSignature()
        //ignore: avoid_print
        .then((value) => print('signature - $value'));

    controller = OTPTextEditController(
      codeLength: 4,
      autoStop: true,
      //ignore: avoid_print
      onCodeReceive: (code) => print('Your Application receive code - $code'),
      otpInteractor: _otpInteractor,
    )..startListenUserConsent(
        (code) {
          String OTP = code!.replaceAll(new RegExp(r'[^0-9]'), '');

          setState(() {
            otpControll.text = "";
            otpControll.text = OTP.toString();
          });

          submit();
          final exp = RegExp(r'(\d{4})');
          return exp.stringMatch(code) ?? '';
        },
        // strategies: [
        //   // SampleStrategy(),
        // ],
      );
  }

  void submit() async {
    showLaoding(context);
    LoginAPI()
        .otpVerify(widget.phoneNumber.toString(), otpControll.text.toString())
        .then((value) {
      Navigator.of(context, rootNavigator: true).pop();
      if (value) {
        //sent to signup screen

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Record not found. Please signup"),
              duration: Duration(seconds: 2)),
        );

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => SignUpScreen(
                      phoneNumber: widget.phoneNumber.toString(),
                    )));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Logged In"),
              duration: Duration(microseconds: 500)),
        );
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
            (route) => false);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listenSMS();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back_outlined,
              color: Colors.black,
              size: 22,
            )),
        elevation: 3,
        leadingWidth: 30,
        title: const Text(
          "OTP verification",
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black, fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          children: [
            Text(
              "We've sent a verification code to",
            ),
            Text("+91 " + widget.phoneNumber.toString()),
            SizedBox(
              height: 25,
            ),
            PinCodeTextField(
              appContext: context,
              mainAxisAlignment: MainAxisAlignment.center,
              length: 4,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeColor: Colors.black,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.black,
                  borderWidth: 1,
                  fieldOuterPadding: EdgeInsets.all(5)
                  // activeFillColor: Colors.white,
                  ),
              cursorColor: Colors.black,
              animationDuration: const Duration(milliseconds: 300),
              // enableActiveFill: true,

              controller: otpControll,
              keyboardType: TextInputType.number,
              boxShadows: const [
                BoxShadow(
                  offset: Offset(0, 1),
                  color: Colors.white,
                  blurRadius: 10,
                )
              ],
              onCompleted: (v) {
                submit();
              },
              onChanged: (value) {},
            ),
            SizedBox(
              height: 30,
            ),
            InkWell(
              child: Text("Resend OTP"),
              onTap: () {
                showLaoding(context);

                LoginAPI()
                    .userLogin(widget.phoneNumber.toString())
                    .then((value) {
                  if (value['ErrorCode'] == 100) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("OTP Sent".toString()),
                          duration: Duration(seconds: 1)),
                    );
                    listenSMS();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(value['ErrorMessage'].toString()),
                          duration: Duration(seconds: 1)),
                    );
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
