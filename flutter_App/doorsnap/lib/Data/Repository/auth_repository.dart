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
      UserCredential userCredential = await auth
          .signInAnonymously(); // we signin anonymously  then we will link this with password and make this parmnanent

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

  Future<UserModel> userDetails({
    required String fullName,
    required String username,
    required String address,
  }) async {
    try {
      final usernameExists = await checkUsernameExists(username);
      if (usernameExists) {
        throw Exception("username already exists");
      }

      final userData = UserModel(
        fullname: fullName,
        username: username,
        address: address,
      );
      final uid = auth.currentUser!.uid;      // this is after when we have user authentication has been already done
      final updatedData = {
        'fullName': fullName,
        'username': username,
        'address': address,
      };
      await updateUserData(uid, updatedData);
      return userData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  // save created user data to firestore  by maping the user model to a map
  Future<void> saveUserData(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).set(user.toMap());
      log('User data saved successfully to Firestore');
    } catch (e) {
      log('Error saving user data: $e');
      throw "Failed to save user data: $e";
    }
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> updatedData) async {
    try {
      await firestore.collection('users').doc(uid).update(updatedData);
      log('User data updated successfully in Firestore');
    } catch (e) {
      log('Error updating user data: $e');
      throw "Failed to update user data: $e";
    }
  }

  

  Future<bool> checkUsernameExists(String username) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('error checking username $e');
      return false;
    }
  }
}
