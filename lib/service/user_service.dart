// ignore_for_file: avoid_print

import "../model/user_data.dart";
import '../repo/user_repo.dart';

class UserService {
  final userRepo = UserRepo();

  // Get user data
  Future<UserData?> getUserData(String userId) async {
    try {
      final userData = await userRepo.fetchUserData(userId);
      if (userData != null) {
        print("user service: $userData");
        return UserData.fromJson(Map<String, dynamic>.from(userData));
      } else {
        print("User data not found for userId: $userId");
        return null;
      }
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      return await userRepo.userExists(userId);
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  // Add user to the database new signup
  addUser(String uid, String name) {
    userRepo.addUser(uid, {"name": name});
  }
}
