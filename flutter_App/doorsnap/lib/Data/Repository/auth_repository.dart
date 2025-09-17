import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doorsnap/Data/Models/user_model.dart';
import 'package:doorsnap/Data/Service/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository extends BaseRepository {
  Future<UserModel> emailPhoneDetails({
    required String email,
    required String phoneNumber,
    String? fcmToken,
  }) async {
    try {
      UserCredential userCredential = await auth
          .signInAnonymously(); // we signin anonymously  then we will link this with password and make this parmnanent

      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        phoneNumber: phoneNumber,
        fcmToken: fcmToken,
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
    log('Attempting to get user data for UID: $uid');
    final doc = await firestore.collection("users").doc(uid).get();
    
    if (!doc.exists) {
      log('User document not found for UID: $uid');
      
      // Check if there's a document with this email instead
      final currentUser = auth.currentUser;
      if (currentUser?.email != null) {
        log('Searching for user by email: ${currentUser!.email}');
        final querySnapshot = await firestore
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .limit(1)
            .get();
            
        if (querySnapshot.docs.isNotEmpty) {
          log('Found user document by email, updating UID');
          final userData = querySnapshot.docs.first.data();
          
          // Update the document with correct UID
          await firestore.collection('users').doc(uid).set(userData);
          
          // Delete old document if UID is different
          if (querySnapshot.docs.first.id != uid) {
            await firestore.collection('users').doc(querySnapshot.docs.first.id).delete();
          }
          
          return UserModel.fromFirestore(await firestore.collection("users").doc(uid).get());
        }
      }
      
      throw "User document not found for UID: $uid";
    }
    
    log('Successfully retrieved user data for UID: $uid');
    return UserModel.fromFirestore(doc);
  } catch (e) {
    log('Error getting user data for UID $uid: $e');
    throw "Failed to get user data: ${e.toString()}";
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
      
      log('Email/password linked successfully to: ${linkedCredential.user!.uid}');  
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



  // for FCM token update
  Future<void> updateFcmToken(String uid, Map<String, dynamic> updatedToken) async {
  try {
    await firestore.collection('users').doc(uid).update(updatedToken);
    log('FCM token updated successfully in Firestore');
  } catch (e) {
    log('Error updating FCM token: $e');
    throw "Failed to update FCM token: $e";
  }
}

Future<UserModel> deviceFcmToken({
  required String fcmToken,
}) async {
  try {
    final userFcmData = UserModel(
      fcmToken: fcmToken,
    );
    final uid = auth.currentUser!.uid;
    final updatedFcmToken = {
      'fcmToken': fcmToken,
    };
    await updateFcmToken(uid, updatedFcmToken);
    return userFcmData;
  } catch (e) {
    log(e.toString());
    rethrow;
  }
}

  
// Update user's profile image URL in Firestore
Future<void> updateProfileImage(String uid, String imageUrl) async {
  try {
    await firestore.collection('users').doc(uid).update({
      'profileImageUrl': imageUrl,
      'profileUpdatedAt': Timestamp.now(),
    });
    log('Profile image updated successfully in Firestore');
  } catch (e) {
    log('Error updating profile image: $e');
    throw "Failed to update profile image: $e";
  }
}


// Get user's profile image URL from Firestore
Future<String?> getUserProfileImage(String uid) async {
  try {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['profileImageUrl'];
    }
    return null;
  } catch (e) {
    log('Error getting user profile image: $e');
    return null;
  }
}


// Clear user-specific data from SharedPreferences on logout
Future<void> clearUserSpecificData(String uid) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear user-specific keys
    await prefs.remove('uploadedImageUrl_$uid');
    await prefs.remove('userProfileCache_$uid');
    // Add any other user-specific keys you might have
    
    log('User-specific data cleared for UID: $uid');
  } catch (e) {
    log('Error clearing user-specific data: $e');
  }
}

}
