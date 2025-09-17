import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? uid;
  final String? fullname;
  final String ?username;
  final String? email;
  final String? phoneNumber;                           
  final String? address;
  final Timestamp createdAt;
  final String? fcmToken;
  final String? deviceId;
  final String? profileImageUrl;

  UserModel({
    this.uid,
    this.fullname,
    this.username,
    this.email,
    this.phoneNumber,
    this.address,
    Timestamp? createdAt,
    this.fcmToken,
    this.deviceId,
    this.profileImageUrl,
  }) : createdAt = createdAt ?? Timestamp.now();

  UserModel copyWith({
    String? uid,
    String? fullname,
    String? username,
    String? email,
    String? phoneNumber,
    String? address,
    Timestamp? createdAt,
    String? fcmToken,
    String? deviceId,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceId: deviceId ?? this.deviceId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }


  // to make fields in firestore db

  Map<String, dynamic> toMap(){
    return {
      "fullName" : fullname,
      "username" : username,
      "email" : email,
      "phoneNumber" : phoneNumber,
      "address" : address,
      "createdAt" : createdAt,
      "fcmToken" : fcmToken,
      "deviceId" : deviceId,
      "profileImageUrl" : profileImageUrl,
    };

  }



  //It allows our Flutter app to convert a Firestore user document into a usable Dart object (UserModel),
  // so we can easily access user info in our app code.

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,                                         
      fullname: data['fullName'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      fcmToken: data['fcmToken'],
      deviceId: data['deviceId'] ?? '',
      profileImageUrl: data['profileImageUrl'],
    );
  }
}
