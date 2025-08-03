import 'dart:developer';

import 'package:doorsnap/Data/Models/user_model.dart';
import 'package:doorsnap/Data/Service/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository extends BaseRepository {
  Future<UserModel> emailPhoneDetails({
    required String email,
    required String phoneNumber,
  }) async {
    try {
      UserCredential userCredential = await auth.signInAnonymously(); // we signin anonymously  then we will link this with password and make this parmnanent

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        phoneNumber: phoneNumber,
      );
      await saveUserData(user);
      return user;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // save created user data to firestore  by maping the user model to a map
  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap()); 
      log('User data saved successfully to Firestore');
    } catch (e) {
      log('Error saving user data: $e');
      throw "Failed to save user data: $e";
    }
  }
}
