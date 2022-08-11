import 'dart:async';

import 'package:chat_app/Authenticate/Autheticate.dart';
import 'package:chat_app/Authenticate/SignInNum.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Screens/tabs_basic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High Importance Notifications',
    // 'This channel is used for important notification',
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin FlutterLocalNotifications =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('fsdff: ${message.messageId}');
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FlutterLocalNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var phone = prefs.getString('phone');
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: phone == null ? SignInNum() : MyApp()));
      // home:  SignInNum()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        routes: <String, WidgetBuilder>{
          '/HomeRoute': (BuildContext context) => new TabsBasicRoute(),
        });
  }
}

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  startTime() async {
    var duration = new Duration(seconds: 1);
    return new Timer(duration, navigationPage);
  }



// Notification Testing 
// 
// void showNotification(){
//   setState(() {
    
//   });
//   FlutterLocalNotifications.show(
//            0,"Testing","How are you",
//             NotificationDetails(
//                 android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               // channel.description,
//               color: Colors.cyan[800],
//               playSound: true,
//               icon: '@mipmap/ic_launcher',
//             )));
// }


  @override
  void initState() {
    super.initState();
    startTime();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notifications = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notifications != null && android != null) {
        FlutterLocalNotifications.show(
            notifications.hashCode,
            notifications.title,
            notifications.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // channel.description,
              color: Colors.cyan[800],
              playSound: true,
              icon: '@mipmap/ic_launcher',
            )));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("new message published");
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title.toString()),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(notification.body.toString())],
                  ),
                ),
              );
            });
      }
    });
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed('/HomeRoute');
  }

// SplashScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      body: Align(
        child: Container(
          width: 150,
          height: 150,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                child: Icon(Icons.chat),
              ),
              Container(height: 5),
        
              Row(
                children: [
                  Text("CHAT",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      )),
                  Text(" APP",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.cyan[800],
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              Text(
                "Let's Chat",
              ),
              Column(
                children: [
                  Container(height: 20),
                ],
              ),
              Container(
                height: 3,
                width: 80,
                child: LinearProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.cyan.shade800),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
        alignment: Alignment.center,
      ),
    );
  }
}
