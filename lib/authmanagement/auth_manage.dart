import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

exceptionHandler(String errorCode) {
  switch (errorCode) {
    case 'invalid-credential':
      return 'Your login credentials are invalid. Please try again.';
    case 'weak-password':
      return 'The password myst be longer than 6 characters.';
    case 'email-already-in-use':
      return 'The email address is already in use.';
    case 'user-not-found':
      return 'No user found with this email.';
    case 'invalid-email':
      return 'Invalid email format.';
    case 'wrong-password':
      return 'Invalid credentials Email ID or password';
    default:
      return 'An unexpected error occurred.';
  }
}

class AuthManage {
  final _auth = FirebaseAuth.instance;
  
  // ---------------------------- Google Login ------------------------------------- //
  // Logo In with Google
  Future<UserCredential?> LoginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();

      // Sign out to ensure account selection prompt
      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }

  // ---------------------------- Common function ------------------------------------- //

  // getUserID() fnction to get the current user ID
  String getUserID() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  // logout() function to sign out the current user
  Future<void> logout() async {
    await _auth.signOut();
  }
}