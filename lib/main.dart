// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:instadent/PushNotificationService.dart';
import 'package:instadent/UpdateCart.dart';
import 'package:instadent/dashboard.dart';
import 'package:instadent/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService().setupInteractedMessage();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    runApp(const MyApp());
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // App received a notification when it was killed
    }
  });
  // runApp(const MyApp());
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
        theme: ThemeData(fontFamily: 'Roboto-Regular'),
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

  bool fetchingLocation = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Timer(Duration(seconds: 4), () async {
      if (await Geolocator.isLocationServiceEnabled()) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: SizedBox(
                    height: 180,
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/location_loading.gif",
                                scale: 5,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Getting your location",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 16),
                              )
                            ])))));
        _determinePosition().then((value) {
          _getAddress(value).then((value) {
            Navigator.of(context).pop();
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
        });
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: SizedBox(
                    height: 180,
                    child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                "Location services are disabled. Please enable location and restart your app."
                                    .toString()),
                            ElevatedButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  setState(() {
                                    DashboardState.currentTab = 0;
                                  });

                                  await prefs.clear().then((value) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SplashScreen()),
                                            (route) => false);
                                  });
                                  Provider.of<UpdateCartData>(context,
                                          listen: false)
                                      .showCartorNot();
                                },
                                child: Text("Restart App"))
                          ],
                        )))));
      }
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
      pref.setString("pincode", place.postalCode.toString());
      pref.setString("address_type", place.subLocality.toString());

      pref.setString("defaultAddress",
          "${place.subAdministrativeArea} ,${place.name} ,${place.subLocality} ,${place.locality} ,${place.postalCode} ,${place.country}");
      pref.setString("subLocality", place.subLocality.toString());
      List temp = [
        {
          "address_type": place.subLocality.toString(),
          "address":
              "${place.subAdministrativeArea} ,${place.name} ,${place.subLocality} ,${place.locality} ,${place.postalCode} ,${place.country}",
          "pincode": place.postalCode.toString()
        }
      ];
      pref.setString("recent_address_list", jsonEncode(temp));
      Provider.of<UpdateCartData>(context, listen: false).setDefaultAddress();
    });
  }
}
