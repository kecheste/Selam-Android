import 'package:selam/data/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyUser extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String? age;
  final DateTime? dob;
  final String? bio;
  final String? gender;
  final String? profilePicture;
  final List<dynamic>? images;
  final List<dynamic>? interestedIn;
  final Timestamp createdAt;
  final String? location;
  final String? jobTitle;
  final bool? isOnline;

  const MyUser(
      {required this.id,
      required this.phone,
      required this.name,
      required this.gender,
      required this.bio,
      required this.dob,
      required this.age,
      required this.profilePicture,
      required this.images,
      required this.interestedIn,
      required this.createdAt,
      required this.location,
      required this.jobTitle,
      required this.isOnline});

  toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'gender': gender,
      'bio': bio,
      'age': age,
      'dob': dob != null ? Timestamp.fromDate(dob!) : null,
      'profilePicture': profilePicture,
      'images': images,
      'interestedIn': interestedIn,
      'createdAt': createdAt,
      'location': location,
      'jobTitle': jobTitle,
      'status': isOnline
    };
  }

  static final empty = MyUser(
      id: "",
      phone: "",
      name: "",
      profilePicture: "",
      dob: null,
      gender: "",
      bio: "",
      age: "",
      images: const [],
      interestedIn: const [],
      createdAt: Timestamp.now(),
      location: "",
      jobTitle: "",
      isOnline: false);

  MyUser copyWith(
      {String? id,
      String? phone,
      String? name,
      String? profilePicture,
      String? age,
      String? gender,
      DateTime? dob,
      List<dynamic>? images,
      String? bio,
      List<dynamic>? interestedIn,
      Timestamp? createdAt,
      String? location,
      String? jobTitle,
      bool? isOnline}) {
    return MyUser(
        id: id ?? this.id,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        age: age ?? this.age,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        bio: bio ?? this.bio,
        images: images ?? this.images,
        profilePicture: profilePicture ?? this.profilePicture,
        interestedIn: interestedIn ?? this.interestedIn,
        createdAt: createdAt ?? this.createdAt,
        location: location ?? this.location,
        jobTitle: jobTitle ?? this.jobTitle,
        isOnline: isOnline ?? this.isOnline);
  }

  bool get isEmpty => this == MyUser.empty;
  bool get isNotEmpty => this != MyUser.empty;

  MyUserEntity toEntity() {
    return MyUserEntity(
        id: id,
        phone: phone,
        name: name,
        age: age,
        gender: gender,
        dob: dob,
        bio: bio,
        profilePicture: profilePicture,
        images: images,
        interestedIn: interestedIn,
        createdAt: createdAt,
        location: location,
        jobTitle: jobTitle,
        isOnline: isOnline);
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
        id: entity.id,
        phone: entity.phone,
        name: entity.name,
        age: entity.age,
        gender: entity.gender,
        dob: entity.dob,
        bio: entity.bio,
        profilePicture: entity.profilePicture,
        images: entity.images,
        interestedIn: entity.interestedIn,
        createdAt: entity.createdAt,
        location: entity.location,
        jobTitle: entity.jobTitle,
        isOnline: entity.isOnline);
  }

  @override
  List<Object?> get props => [
        id,
        name,
        age,
        gender,
        phone,
        bio,
        profilePicture,
        interestedIn,
        images,
        dob,
        createdAt,
        location,
        jobTitle,
        isOnline
      ];

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      id: map['id'],
      phone: map['phone'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      dob: map['dob'] != null ? (map['dob'] as Timestamp).toDate() : null,
      bio: map['bio'],
      profilePicture: map['profilePicture'],
      images: map['images'],
      interestedIn: map['interestedIn'],
      createdAt: map['createdAt'] as Timestamp,
      location: map['location'],
      jobTitle: map['jobTitle'],
      isOnline: map['status'],
    );
  }
}
