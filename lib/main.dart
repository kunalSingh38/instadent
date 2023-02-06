// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:location/location.dart' as loc;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:biz_sales_admin/PushNotificationService.dart';
import 'package:biz_sales_admin/UpdateCart.dart';
import 'package:biz_sales_admin/dashboard.dart';
import 'package:biz_sales_admin/login.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "Main Navigator");
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  await PushNotificationService().setupInteractedMessage(navigatorKey);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(MyApp());
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // App received a notification when it was killed
    }
  });
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UpdateCartData>(
      create: (BuildContext context) => UpdateCartData(),
      child: MaterialApp(
        title: 'Instadent',
        theme: ThemeData(fontFamily: 'Roboto-Regular'),
        home: SplashScreen(),
        navigatorKey: navigatorKey,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 4), () async {
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
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Image.asset("assets/singleSplash.gif"),
    );
  }
}
