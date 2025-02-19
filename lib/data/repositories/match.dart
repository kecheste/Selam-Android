import 'package:selam/config/app_config.dart';
import 'package:selam/data/entities/user_entity.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchRepository {
  final matchesCollection =
      FirebaseFirestore.instance.collection(AppConfig.matchesCollection);
  final usersCollection =
      FirebaseFirestore.instance.collection(AppConfig.usersCollection);

  Future<List<MyUser>> getMatches() async {
    List<MyUser> results = [];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    var matches = await matchesCollection
        .where("users", arrayContains: currentUserId)
        .get();

    List<String> otherUserIds = [];

    for (var doc in matches.docs) {
      var users = List<String>.from(doc.data()["users"] ?? []);
      var otherUserId =
          users.firstWhere((id) => id != currentUserId, orElse: () => "");

      if (otherUserId.isNotEmpty) {
        otherUserIds.add(otherUserId);
      }
    }

    if (otherUserIds.isNotEmpty) {
      var usersData = await usersCollection
          .where(FieldPath.documentId, whereIn: otherUserIds)
          .get();

      results = usersData.docs
          .map((e) => MyUser.fromEntity(MyUserEntity.fromDocument(e.data())))
          .toList();
    }

    return results;
  }

  Stream<List<MyUser>> streamPossibleMatches() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return usersCollection
        .doc(currentUserId)
        .snapshots()
        .asyncExpand((userSnapshot) {
      if (!userSnapshot.exists) return Stream.value([]);

      var currentUser =
          MyUser.fromEntity(MyUserEntity.fromDocument(userSnapshot.data()!));
      var desiredGender = currentUser.gender == 'Male' ? 'Female' : 'Male';

      return usersCollection
          .where("gender", isEqualTo: desiredGender)
          .where("profilePicture", isNotEqualTo: "")
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) =>
                  MyUser.fromEntity(MyUserEntity.fromDocument(doc.data())))
              .toList());
    });
  }

  Future<List<MyUser>> getPossibleMatches() async {
    List<MyUser> results = [];
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    var currentUserDoc = await usersCollection.doc(currentUserId).get();
    if (!currentUserDoc.exists) return [];

    var currentUser =
        MyUser.fromEntity(MyUserEntity.fromDocument(currentUserDoc.data()!));
    var desiredGender = currentUser.gender == 'Male' ? 'Female' : 'Male';

    try {
      var result = await usersCollection
          .where('gender', isEqualTo: desiredGender)
          .where('profilePicture', isNotEqualTo: "")
          .get();

      results = result.docs
          .map((e) => MyUser.fromEntity(MyUserEntity.fromDocument(e.data())))
          .toList();

      return results;
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MyUser>> streamMatches() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return matchesCollection
        .where("users", arrayContains: currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<String> otherUserIds = [];

      for (var doc in snapshot.docs) {
        var users = List<String>.from(doc.data()["users"] ?? []);
        var otherUserId =
            users.firstWhere((id) => id != currentUserId, orElse: () => "");

        if (otherUserId.isNotEmpty) {
          otherUserIds.add(otherUserId);
        }
      }

      if (otherUserIds.isEmpty) return [];

      var usersData = await usersCollection
          .where(FieldPath.documentId, whereIn: otherUserIds)
          .get();

      return usersData.docs
          .map((e) => MyUser.fromEntity(MyUserEntity.fromDocument(e.data())))
          .toList();
    });
  }

  Future<List<MyUser>> getMatchesByLocation() async {
    List<MyUser> results = [];
    final currentUser = await usersCollection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) =>
            MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    var desiredGender = currentUser.gender == 'Male' ? 'Female' : 'Male';

    try {
      final result = await usersCollection
          .where('gender', isEqualTo: desiredGender)
          .where('profilePicture', isNotEqualTo: "")
          .get();
      final unfiltered = result.docs
          .map((e) => MyUser.fromEntity(MyUserEntity.fromDocument(e.data())))
          .toList();
      results = unfiltered
          .where((element) => element.location! == currentUser.location!)
          .toList();
      return results;
    } catch (e) {
      rethrow;
    }
  }
}
