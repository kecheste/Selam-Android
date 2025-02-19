import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:xid/xid.dart';
import 'package:http/http.dart' as http;
import 'package:selam/config/app_config.dart';

class ChatRepository {
  final chatCollection =
      FirebaseFirestore.instance.collection(AppConfig.chatsCollection);
  final usersCollection =
      FirebaseFirestore.instance.collection(AppConfig.usersCollection);

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await chatCollection.doc(chatRoomId).get();
    if (snapshot.exists) {
      return true;
    } else {
      return chatCollection.doc(chatRoomId).set(chatRoomInfoMap);
    }
  }

  sendMessage(
      String chatRoomId, Map<String, dynamic> messageInfoMap, String toUserId) {
    String messageId = Xid().toString();
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    try {
      return chatCollection
          .doc(chatRoomId)
          .collection("chats")
          .doc(messageId)
          .set(messageInfoMap);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      sendNotificationToUser(toUserId, "message", currentUserId);
    }
  }

  sendNotificationToUser(receiverId, featureType, senderId) async {
    String userDeviceToken = "";
    String senderName = "";
    await usersCollection.doc(receiverId).get().then((snapshot) {
      if (snapshot.data()!['fcmToken'] != null) {
        userDeviceToken = snapshot.data()!['fcmToken'].toString();
      }
    });

    await usersCollection.doc(senderId).get().then((snapshot) {
      if (snapshot.data()!['name'] != null) {
        senderName = snapshot.data()!['name'].toString();
      }
    });

    notificationFormat(userDeviceToken, receiverId, featureType, senderName);
  }

  notificationFormat(userDeviceToken, receiverid, featureType, senderName) {
    final currentUserid = FirebaseAuth.instance.currentUser!.uid;

    String serverKey =
        "key=${String.fromEnvironment('NOTIFICATION_SERVER_KEY', defaultValue: "")}";
    Map<String, String> headerNotification = {
      "Content-Type": "application/json",
      "Authorization": serverKey
    };

    Map notificationBody = {
      "body": "You have received a new $featureType from $senderName.",
      "title": "New $featureType",
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userId": receiverid,
      "senderid": currentUserid,
    };

    Map notificationOfficialFormat = {
      "notification": notificationBody,
      "data": dataMap,
      "priority": "high",
      "to": userDeviceToken,
    };

    http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(notificationOfficialFormat),
    );
  }

  updateLastMessageSent(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return chatCollection.doc(chatRoomId).update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatMessages(chatRoomId) async {
    return chatCollection
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("sentDate", descending: true)
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    String? myId = FirebaseAuth.instance.currentUser!.uid;
    return chatCollection
        .orderBy("dateSent", descending: true)
        .where("users", arrayContains: myId)
        .snapshots();
  }
}
