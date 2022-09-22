// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:geolocator/geolocator.dart';
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
  // Future<Position> _determinePosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     await Geolocator.requestPermission();
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }

  // void showlocationPermission() async {
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.always) {
  //     Timer(Duration(milliseconds: 2500), () {
  //       checkLoggedIn().then((value) {
  //         if (value) {
  //           Provider.of<UpdateCartData>(context, listen: false)
  //               .incrementCounter();
  //           Navigator.pushReplacement(
  //             context,
  //             MaterialPageRoute(builder: (context) => Dashboard()),
  //           );
  //         } else {
  //           Navigator.of(context).pushReplacement(MaterialPageRoute(
  //               builder: (BuildContext context) => LoginScreen()));
  //         }
  //       });
  //     });
  //   } else {
  //     showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => AlertDialog(
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.all(Radius.circular(20))),
  //               title: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Image.asset(
  //                     "assets/map2.png",
  //                     scale: 10,
  //                   ),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   Text(
  //                     "Use your location",
  //                     style:
  //                         TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //                   ),
  //                 ],
  //               ),
  //               actionsAlignment: MainAxisAlignment.spaceBetween,
  //               actions: [
  //                 TextButton(
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                       showlocationPermission();
  //                     },
  //                     child: Text(
  //                       "NO THANKS",
  //                       style: TextStyle(color: Colors.green[800]),
  //                     )),
  //                 TextButton(
  //                     onPressed: () async {
  //                       _determinePosition().then((value) {
  //                         Timer(Duration(milliseconds: 2500), () {
  //                           checkLoggedIn().then((value) {
  //                             if (value) {
  //                               Provider.of<UpdateCartData>(context,
  //                                       listen: false)
  //                                   .incrementCounter();
  //                               Navigator.pushReplacement(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => Dashboard()),
  //                               );
  //                             } else {
  //                               Navigator.of(context).pushReplacement(
  //                                   MaterialPageRoute(
  //                                       builder: (BuildContext context) =>
  //                                           LoginScreen()));
  //                             }
  //                           });
  //                         });
  //                       });
  //                     },
  //                     child: Text(
  //                       "TURN ON",
  //                       style: TextStyle(color: Colors.green[800]),
  //                     ))
  //               ],
  //               content: Text(
  //                 "This application collects location data to show near by store. We don't collect your location data.",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
  //               ),
  //             ));
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (Platform.isAndroid) {
    //   WidgetsBinding.instance
    //       .addPostFrameCallback((_) => showlocationPermission());
    // } else {
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
