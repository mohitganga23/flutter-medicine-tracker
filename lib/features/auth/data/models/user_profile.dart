import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final String name;
  final String age;
  final String gender;
  final String profilePhotoUrl;
  final DateTime createdOn;

  UserModel({
    required this.username,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.profilePhotoUrl,
    required this.createdOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'profile_photo_url': profilePhotoUrl,
      'created_on': createdOn,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? '-',
      gender: map['gender'] ?? '-',
      profilePhotoUrl: map['profile_photo_url'] ?? '',
      createdOn: (map['created_on'] as Timestamp).toDate(),
    );
  }
}
