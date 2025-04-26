// ignore_for_file: avoid_print

import 'package:astraval_smart/utils/map_converter.dart';
import 'package:firebase_database/firebase_database.dart';

class UserRepo {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Add a new user to Firebase Realtime Database
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _dbRef.child('users/$userId').set(userData);
      print('User added successfully: $userId');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  // Fetch user data from Firebase Realtime Database
  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final dbEvent = await _dbRef.child('users/$userId').once();
      if (dbEvent.snapshot.exists) {
        final data = dbEvent.snapshot.value;
        print("user repo: $data");
        return convertToMapStringDynamic(data);
      } else {
        print('No data available for user: $userId');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Update user data in Firebase Realtime Database
  Future<void> updateUserData(
      String userId, Map<String, dynamic> userData) async {
    try {
      await _dbRef.child('users/$userId').update(userData);
      print('User data updated successfully: $userId');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Delete user data from Firebase Realtime Database
  Future<void> deleteUserData(String userId) async {
    try {
      await _dbRef.child('users/$userId').remove();
      print('User data deleted successfully: $userId');
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  // Check if the user exists in the database
  Future<bool> userExists(String userId) async {
    try {
      final dbEvent = await _dbRef.child('users/$userId').once();
      return dbEvent.snapshot.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }
}
