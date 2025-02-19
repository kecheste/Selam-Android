import 'package:selam/config/app_config.dart';
import 'package:selam/data/entities/user_entity.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final usersCollection =
      FirebaseFirestore.instance.collection(AppConfig.usersCollection);
  final userRepository = UserRepository();

  Stream<User?> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser;
      return user;
    });
  }

  static String verifyId = "";

  Future sendOtp(
      {required String phone,
      required Function errorStep,
      required Function nextStep}) async {
    await _firebaseAuth
        .verifyPhoneNumber(
      timeout: const Duration(seconds: 120),
      phoneNumber: phone,
      verificationCompleted: (phoneAuthCredential) async {
        return;
      },
      verificationFailed: (error) async {
        errorStep();
        return;
      },
      codeSent: (verificationId, forceResendingToken) async {
        verifyId = verificationId;
        nextStep();
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        return;
      },
    )
        .onError((error, stackTrace) {
      errorStep();
    });
  }

  Future loginWithOtp({required String otp, required String phone}) async {
    final PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);
    try {
      final user = await _firebaseAuth.signInWithCredential(credential);

      if (user.user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found after sign in',
        );
      }

      final checkUserFound = await usersCollection.doc(user.user!.uid).get();
      if (!checkUserFound.exists) {
        MyUser addedUser = MyUser(
          id: user.user!.uid,
          phone: phone,
          name: "",
          gender: "",
          bio: "",
          age: "",
          profilePicture: "",
          interestedIn: const [],
          createdAt: Timestamp.now(),
          dob: null,
          location: "",
          jobTitle: "",
          isOnline: true,
          images: const [],
        );
        await usersCollection
            .doc(user.user!.uid)
            .set(addedUser.toEntity().toDocument());
        return addedUser;
      } else {
        final MyUser existingUser = await getMyUser(user.user!.uid);
        await userRepository.updateStatus(true, user.user!.uid);
        return existingUser;
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<MyUser> updateUser(MyUser updatedUser) async {
    try {
      await usersCollection
          .doc(updatedUser.id)
          .update(updatedUser.toEntity().toDocument());
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  Stream<MyUser> getUserStream(String userId) {
    return FirebaseFirestore.instance
        .collection(AppConfig.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) =>
            MyUser.fromEntity(MyUserEntity.fromDocument(snapshot.data()!)));
  }

  Future<void> signOut() async {
    await userRepository.updateStatus(false, _firebaseAuth.currentUser!.uid);
    await _firebaseAuth.signOut();
  }

  Future<MyUser> getMyUser(String myUserId) async {
    try {
      return usersCollection.doc(myUserId).get().then((value) =>
          MyUser.fromEntity(MyUserEntity.fromDocument(value.data()!)));
    } catch (e) {
      rethrow;
    }
  }
}
