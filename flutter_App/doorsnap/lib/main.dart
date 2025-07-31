import 'package:doorsnap/Data/Service/service_locator.dart';
import 'package:doorsnap/Presentation/home/screen/auth/login_screen.dart';
import 'package:doorsnap/Router/app_router.dart';
import 'package:doorsnap/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupserviceLocator(); // Initialize the service locator
  runApp(const MyApp());
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
