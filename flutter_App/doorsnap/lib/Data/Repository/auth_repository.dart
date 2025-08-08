import 'dart:developer';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsnap/Data/Models/user_model.dart';
import 'package:doorsnap/Data/Service/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:flutter/material.dart';

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
        throw Exception("Username already exists");
        
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


  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await firestore.collection("users").doc(uid).get();
      if (!doc.exists){
        throw "User not found";
      }
      return UserModel.fromFirestore(doc);
    }catch (e) {
      throw "Failed to get user data";
    }
  }



  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password);
        if (userCredential.user == null){
          throw "User not found";
        }
        final userData = await getUserData(userCredential.user!.uid);
        return userData;
    }catch (e) {
      log(e.toString());
      rethrow;
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


  // link email/password to anonymous account
  Future<void> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try{

      log("starting email password linking...");

      if (auth.currentUser == null){
        throw Exception("no current user to link credentialto ");
      }

      String currentUid = auth.currentUser!.uid;
      log("Linking credential to user $currentUid");

      
      // Create email/password credential
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: email,
        password: password,
      );



      UserCredential linkedCredential = await auth.currentUser!.linkWithCredential(credential);
      
      if (linkedCredential.user == null) {
        throw Exception('Linking failed - no user returned');
      }
      
      log('✅ Email/password linked successfully to: ${linkedCredential.user!.uid}');

      

    }catch(e){
      print("Error linking email and passwoed");
      throw Exception("Failed to link email/password: $e");
    }
     

  }


  Future<void> updateDeviceIdData(String uid, Map<String, dynamic> updatedDeviceData) async {
    try {
      await firestore.collection('users').doc(uid).update(updatedDeviceData);
      log('Device ID updated successfully in Firestore');
    } catch (e) {
      log('Error updating device ID: $e');
      throw "Failed to update device ID: $e";
    }
  }


    Future<UserModel> deviceIdDetails({
    required String deviceId,
  }) async {
    try {
      

      final userDeviceData = UserModel(
        deviceId: deviceId,
      );
      final uid = auth.currentUser!.uid;      // this is after when we have user authentication has been already done
      final updatedDeviceData = {
        'deviceId' : deviceId,
      };
      await updateUserData(uid, updatedDeviceData);
      return userDeviceData;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
