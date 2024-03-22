

import 'dart:convert';
import 'dart:io';
import 'dart:math';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationServices {

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();

  //function to initialise flutter local notification plugin to show notifications for android when app is active
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@drawable/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings ,
        iOS: iosInitializationSettings
    );

    await _flutterLocalNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (payload){
          // handle interaction when app is active for android
          handleMessage(context, message);
        }
    );
  }

  void firebaseInit(BuildContext context){




    FirebaseMessaging.onMessage.listen((message) {

      RemoteNotification? notification = message.notification ;
      AndroidNotification? android = message.notification!.android ;

      if (kDebugMode) {
        print("notifications title:${notification!.title}");
        print("notifications body:${notification.body}");
        print('count:${android!.count}');
        print('data:${message.data.toString()}');
      }

      if(Platform.isIOS){
        forgroundMessage();
      }

      if(Platform.isAndroid){
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }
  // function to show visible notification when app is active
  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        message.notification!.android!.channelId.toString(),
        message.notification!.android!.channelId.toString() ,
        importance: Importance.max  ,
        showBadge: true ,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('')
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString() ,
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high ,
        playSound: true,
        ticker: 'ticker' ,
        // sound: channel.sound
      //     sound: RawResourceAndroidNotificationSound('jetsons_doorbell')
       icon: '@drawable/ic_launcher',
    );

    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true ,
        presentBadge: true ,
        presentSound: true
    ) ;

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero , (){
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails ,

      );
    });

  }



  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context)async{

    // when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage != null){
      handleMessage(context, initialMessage);
    }


    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });

  }

  void handleMessage(BuildContext context, RemoteMessage message) {
  
  //   Map<String, dynamic> dataMap =message.data;
  //   //
  //   print('data:${dataMap['data'].toString()}');
  // //   String jsonString = '''
  // //   {
  // //     "image": "https://rivaplus.neosao.online/storage/public/uploads/offerslider/OS_9.jpg",
  // //     "data": {
  // //       "fromDate": "04-02-2024",
  // //       "toDate": "12-02-2024",
  // //       "language": [
  // //         {"offerDescription": "", "language": "ENGLISH", "offerTitle": "Offer"},
  // //         {"offerDescription": "", "language": "ARABIC", "offerTitle": ""},
  // //         {"offerDescription": "", "language": "KURDISH", "offerTitle": ""}
  // //       ],
  // //       "id": 9,
  // //       "sliderImage": "https://rivaplus.neosao.online/storage/public/uploads/offerslider/OS_9.jpg"
  // //     },
  // //     "random_id": 838,
  // //     "priority": 1,
  // //     "title": "Offer",
  // //     "message": "New offer is added.",
  // //     "android_channel_id": 1001
  // //   }
  // // ''';
  //   String jsonString =json.encode(message.data);
  //   print('encodejsonString===:$jsonString');
  //   print('decodejsonString===:${json.decode(jsonString)}');
  //
  //   // Convert the JSON string to a Dart Map
  //   Map<String, dynamic> jsonData = json.decode(jsonString);
  //
  //   // Create an instance of the Dart classes using the JSON data
  //   OfferNotification offerNotification = createOfferNotification(jsonData);
  //
  //   // Access the values through the objects
  //   print(offerNotification.image);
  //   print(offerNotification.data.fromDate);
  //   print(offerNotification.data.language[0].language);
  //   print(offerNotification.data.id);
  //   print(offerNotification.randomId);
  //
  //   // Map<String, dynamic> dataMap =message.data;
  //   //
  //   // print('data:${dataMap['data'].toString()}');
  //   //
  //   //
  //   // String data =dataMap['data'];
  //   // print('data222122:${data}');
  //   // // Now you can access specific properties within the 'data' field
  //   // String fromDate = dataMap['fromDate'];
  //   // String toDate = dataMap['toDate'];
  //   // List<Map<String, dynamic>> languageArray = List<Map<String, dynamic>>.from(dataMap['language']);
  //   // int id = dataMap['id'];
  //   // String sliderImage = dataMap['sliderImage'];
  //   //
  //   // // Use the extracted values as needed
  //   // print(fromDate);
  //   // print(toDate);
  //   // print(languageArray);
  //   // print(id);
  //   // print(sliderImage);
  //
  //   // ResultSlider slider = ResultSlider.fromJson(dataMap['data']);
  //   late ResultSlider slider = ResultSlider(id: offerNotification.data.id, sliderImage: offerNotification.image, language: offerNotification.data.language, fromDate:  offerNotification.data.fromDate, toDate:  offerNotification.data.toDate);
  //   Navigator.push(context,
  //       MaterialPageRoute(builder: (context) => SlideDetailScreen( slider: slider, language: 'English',)));
  //
  //   if(message.data['type'] =='msj'){
  //     // Navigator.push(context,
  //     //     MaterialPageRoute(builder: (context) => MessageScreen(
  //     //       id: message.data['id'] ,
  //     //     )));
  //   }
  }


  Future forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }


}



