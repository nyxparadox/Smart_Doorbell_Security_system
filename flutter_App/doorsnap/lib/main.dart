import 'package:doorsnap/Data/Service/firebase_messaging_service.dart';
import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Presentation/home/screen/auth/login_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:doorsnap/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



/// 🔔 Local Notifications setup
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupserviceLocator(); // Initialize the service locator

  await requestNotificationPermission(); 
  await initLocalNotifications();
/*
  // ✅ Initialize FCM service with the FirebaseAuth UID (if logged in)
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseMessagingService().initFCM(user.uid);
  }
  */

  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      print("🔐 User logged in: ${user.uid}");
      await FirebaseMessagingService().initFCM(user.uid);
    } else {
      print("🔐 User logged out");
    }
  });

//   Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
    print("📩 Message received: ${message.notification?.title}");

    if (message.notification != null) {
    const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        "doorsnap_channel", // channel id
        "DoorSnap Notifications", // channel name
        importance: Importance.high,
        priority: Priority.high,
      );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // notification id
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
    );
  }
  });

  runApp(const MyApp());
}

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print("🔔 Permission granted: ${settings.authorizationStatus}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoorSnap',
      navigatorKey:
          getIt<AppRouter>().navigatorKey, // Use the AppRouter's navigator key
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 24, 65, 136),
        ),
      ),

      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
