import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<void> updateFCMToken(String userId) async {
    String? token = await _fcm.getToken();
    if (token != null) {
      await saveTokenToFirestore(userId, token);
    }
  }

  Future<void> initFCM(String userId) async {
    // Get the initial FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      await saveTokenToFirestore(userId, token);
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(userId, newToken);
    });
  }

  Future<void> saveTokenToFirestore(String userId, String token) async {
    await FirebaseFirestore.instance.collection("users").doc(userId).set({
      "fcmToken": token,
    }, SetOptions(merge: true));
  }
}