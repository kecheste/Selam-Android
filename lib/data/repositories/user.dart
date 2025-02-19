import 'dart:convert';
import 'dart:typed_data';

import 'package:selam/data/entities/user_entity.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:xid/xid.dart';
import 'package:selam/config/app_config.dart';

class UserRepository {
  final usersCollection =
      FirebaseFirestore.instance.collection(AppConfig.usersCollection);
  final matchesCollection =
      FirebaseFirestore.instance.collection(AppConfig.matchesCollection);

  Future<String> uploadPicture(Uint8List file, String userId) async {
    try {
      Xid xid = Xid();
      Reference firebaseStoreRef = FirebaseStorage.instance
          .ref()
          .child('$userId/images/${xid.toString()}_lead');
      await firebaseStoreRef.putData(file);
      String url = await firebaseStoreRef.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadImages(List<Uint8List> files, String userId) async {
    try {
      List<String> urls = [];
      for (var file in files) {
        String url = await uploadPicture(file, userId);
        urls.add(url);
      }
      await usersCollection.doc(userId).update({'images': urls});
      await usersCollection.doc(userId).update({'profilePicture': urls.first});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateName(String name, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'name': name});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDOB(DateTime dob, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'dob': dob});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGender(String gender, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'gender': gender});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAge(String age, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'age': age});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBio(String bio, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'bio': bio});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLocation(String place, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'location': place});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateJob(String job, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'jobTitle': job});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStatus(bool status, String userId) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserId == userId) {
        await usersCollection.doc(userId).update({'isOnline': status});
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateInterests(List interests, String userId) async {
    try {
      String currentUserid = FirebaseAuth.instance.currentUser!.uid;
      if (currentUserid == userId) {
        await usersCollection.doc(userId).update({'interestedIn': interests});
      }
    } catch (e) {
      rethrow;
    }
  }

  sendFavorite(String toUserId) async {
    final currentUserid = FirebaseAuth.instance.currentUser!.uid;
    var document = await usersCollection
        .doc(toUserId)
        .collection("favoritesRecieved")
        .doc(currentUserid)
        .get();
    var matchCheck = await usersCollection
        .doc(currentUserid)
        .collection("favoritesRecieved")
        .doc(toUserId)
        .get();
    if (document.exists) {
      // REMOVE Favorite
      await usersCollection
          .doc(toUserId)
          .collection("favoritesRecieved")
          .doc(currentUserid)
          .delete();
      await usersCollection
          .doc(currentUserid)
          .collection("favoritesSent")
          .doc(toUserId)
          .delete();

      // Remove match
      if (matchCheck.exists) {
        var matchDocs = await matchesCollection
            .where("users", arrayContains: currentUserid)
            .get();
        for (var doc in matchDocs.docs) {
          if (doc.data()['users'].contains(toUserId)) {
            await doc.reference.delete();
          }
        }
      }
    } else {
      // ADD Favorite
      await usersCollection
          .doc(toUserId)
          .collection("favoritesRecieved")
          .doc(currentUserid)
          .set({});
      await usersCollection
          .doc(currentUserid)
          .collection("favoritesSent")
          .doc(toUserId)
          .set({});
      // Add match if they like each other
      if (matchCheck.exists) {
        Xid matchId = Xid();
        String matchIdString = matchId.toString();
        await matchesCollection.doc(matchIdString).set({
          "users": [toUserId, currentUserid],
        });
      }

      // SEND Notification
      sendNotificationToUser(toUserId, "Like", currentUserid);
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
        "key=${String.fromEnvironment('NOTIFICATION_SERVER_KEY')}";
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

  getFavoriteSenders() async {
    String? myId = FirebaseAuth.instance.currentUser!.uid;
    return usersCollection
        .doc(myId)
        .collection("favoritesRecieved")
        .snapshots();
  }

  Future<MyUser> getUserById(String myUserId) async {
    try {
      return usersCollection.doc(myUserId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (e) {
      rethrow;
    }
  }
}
