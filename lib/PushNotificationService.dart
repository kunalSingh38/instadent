import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class PushNotificationService {
// It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage(
      GlobalKey<NavigatorState> navigatorKey) async {
    await Firebase.initializeApp();
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   if (message.data['type'] == 'carousel') {
    //     Navigator.push(
    //         navigatorKey.currentState!.context,
    //         MaterialPageRoute(
    //             builder: (context) => BannerProductsView(
    //                   id: message.data['data'].toString(),
    //                   banner: true,
    //                   data: [],
    //                 )));
    //   } else if (message.data['type'] == 'category') {
    //     Navigator.push(
    //         navigatorKey.currentState!.context,
    //         MaterialPageRoute(
    //             builder: (context) => SubCategoriesScreen(
    //                 catName: jsonDecode(message.data['data'])['category_name']
    //                     .toString(),
    //                 catId: jsonDecode(message.data['data'])['id'].toString(),
    //                 bannerImage:
    //                     jsonDecode(message.data['data'])['category_banner']
    //                         .toString())));
    //   }
    // });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   if (message.data['type'] == 'carousel') {
    //     Navigator.push(
    //         navigatorKey.currentState!.context,
    //         MaterialPageRoute(
    //             builder: (context) => BannerProductsView(
    //                   id: message.data['data'].toString(),
    //                   banner: true,
    //                   data: [],
    //                 )));
    //   } else if (message.data['type'] == 'category') {
    //     print(jsonDecode(message.data['data'])['category_name'].toString());
    //     print(jsonDecode(message.data['data'])['id'].toString());
    //     print(jsonDecode(message.data['data'])['category_banner'].toString());
    //     Navigator.push(
    //         navigatorKey.currentState!.context,
    //         MaterialPageRoute(
    //             builder: (context) => SubCategoriesScreen(
    //                 catName: jsonDecode(message.data['data'])['category_name']
    //                     .toString(),
    //                 catId: jsonDecode(message.data['data'])['id'].toString(),
    //                 bannerImage:
    //                     jsonDecode(message.data['data'])['category_banner']
    //                         .toString())));
    //   }
    // });

    enableIOSNotifications();
    await registerNotificationListeners();
  }

  Future<void> registerNotificationListeners() async {
    final AndroidNotificationChannel channel = androidNotificationChannel();
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {},
    );
// onMessage is called when the app is in foreground and a notification is received
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      // homeController.getHomeData(
      //   withLoading: false,
      // );
      final RemoteNotification? notification = message!.notification;
      final AndroidNotification? android = message.notification?.android;
// If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(
            await _getByteArrayFromUrl(message.data['bigPicture']));

        final BigPictureStyleInformation bigPictureStyleInformation =
            BigPictureStyleInformation(bigPicture,
                largeIcon: DrawableResourceAndroidBitmap("@mipmap/ic_launcher"),
                contentTitle: notification.title,
                htmlFormatContentTitle: true,
                summaryText: notification.body,
                htmlFormatSummaryText: true);

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              fullScreenIntent: true,
              styleInformation: bigPictureStyleInformation,
            ),
          ),
        );
      }
    });
  }

  Future<void> enableIOSNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  AndroidNotificationChannel androidNotificationChannel() =>
      const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.max,
      );
}
