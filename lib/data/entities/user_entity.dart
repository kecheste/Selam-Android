import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String? age;
  final String? bio;
  final DateTime? dob;
  final String? gender;
  final String? profilePicture;
  final List<dynamic>? images;
  final List<dynamic>? interestedIn;
  final Timestamp createdAt;
  final String? location;
  final String? jobTitle;
  final bool? isOnline;

  const MyUserEntity(
      {required this.id,
      required this.phone,
      required this.name,
      this.gender,
      this.dob,
      this.bio,
      this.age,
      this.profilePicture,
      this.images,
      this.interestedIn,
      required this.createdAt,
      this.location,
      this.jobTitle,
      this.isOnline});

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'gender': gender,
      'bio': bio,
      'dob': dob,
      'age': age,
      'profilePicture': profilePicture,
      'images': images,
      'interestedIn': interestedIn,
      'createdAt': createdAt,
      'location': location,
      'jobTitle': jobTitle,
      'isOnline': isOnline
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
        id: doc['id'] as String,
        phone: doc['phone'] as String,
        name: doc['name'] as String,
        profilePicture: doc['profilePicture'] as String?,
        images: doc['images'] as List<dynamic>?,
        gender: doc['gender'] as String?,
        dob: doc['dob'] != null ? (doc['dob'] as Timestamp).toDate() : null,
        age: doc['age'] as String?,
        bio: doc['bio'] as String?,
        interestedIn: doc['interestedIn'] as List<dynamic>?,
        createdAt: doc['createdAt'] as Timestamp,
        location: doc['location'] as String?,
        jobTitle: doc['jobTitle'] as String?,
        isOnline: doc['isOnline'] as bool?);
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        name,
        age,
        gender,
        dob,
        bio,
        profilePicture,
        images,
        interestedIn,
        createdAt,
        location,
        jobTitle,
        isOnline
      ];

  @override
  String toString() {
    return '''UserEntity: {
      id: $id
      phone: $phone
      name: $name
      age: $age
      gender: $gender
      dob: $dob
      bio: $bio
      profilePicture: $profilePicture
      images: $images
      interestedIn: $interestedIn
      createdAt: $createdAt
      location: $location
      jobTitle: $jobTitle
      status: $isOnline
    }''';
  }
}
