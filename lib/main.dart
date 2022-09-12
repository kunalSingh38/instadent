// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/login.dart';
import 'package:instadent/noInternet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //     options: FirebaseOptions(
  //         apiKey: "AIzaSyDdPB0XxKo6AmLRMglCp7KqHg1P7Sbs3uA",
  //         authDomain: "instadent-3cd58.firebaseapp.com",
  //         projectId: "instadent-3cd58",
  //         storageBucket: "instadent-3cd58.appspot.com",
  //         messagingSenderId: "649776695893",
  //         appId: "1:649776695893:web:5ccd51868c2df05d1262dc",
  //         measurementId: "G-CHNN0KBYTS"));
  await FlutterDownloader.initialize(debug: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  // static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  // static FirebaseAnalyticsObserver observer =
  //     FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateCartData>(
      create: (BuildContext context) => UpdateCartData(),
      child: MaterialApp(
        title: 'Instadent',
        // theme: ThemeData(fontFamily: 'Montserrat'),
        home: SplashScreen(),
        // navigatorObservers: <NavigatorObserver>[observer],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> checkLoggedIn() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool("loggedIn") ?? false;
  }

  // Future<bool> checkIntenert() async {
  //   bool result = await InternetConnectionChecker().hasConnection;
  //   print(result);
  //   return result;
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(milliseconds: 2500), () {
      checkLoggedIn().then((value) {
        if (value) {
          Provider.of<UpdateCartData>(context, listen: false)
              .incrementCounter();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => LoginScreen()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Image.asset("assets/singleSplash.gif"),
    );
  }
}
