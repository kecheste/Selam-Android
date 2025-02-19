import 'package:selam/data/repositories/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotoficationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final UserRepository userRepository = UserRepository();

  Future notificationReceived(BuildContext context) async {
    // 1. When the app is terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        showNotificationData(remoteMessage.data["userId"],
            remoteMessage.data["senderId"], context);
      }
    });
    // 2. When the app is foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        showNotificationData(remoteMessage.data["userId"],
            remoteMessage.data["senderId"], context);
      }
    });
    // 3. When the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        showNotificationData(remoteMessage.data["userId"],
            remoteMessage.data["senderId"], context);
      }
    });
  }

  showNotificationData(receiverId, senderid, context) async {
    await userRepository.usersCollection
        .doc(senderid)
        .get()
        .then((snapshot) {});
  }

  Future generateFCMToken() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    String? deviceToken = await messaging.getToken();
    await userRepository.usersCollection.doc(currentUserId).update({
      'fcmToken': deviceToken,
    });
  }
}
