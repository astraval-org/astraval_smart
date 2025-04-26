import 'package:astraval_smart/page/home/home.dart';
import 'package:astraval_smart/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'page/signin/signin_page.dart';
import 'page/signin/get_user_info.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // While checking authentication state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // If there's an error
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "An error occurred: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              // Check if user is logged in
              if (snapshot.hasData) {
                // User is logged in, check if user exists in RTDB
                return FutureBuilder<bool>(
                  future: userService
                      .userExists(FirebaseAuth.instance.currentUser?.uid ?? ""),
                  builder: (context, userExistsSnapshot) {
                    if (userExistsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (userExistsSnapshot.hasData &&
                        userExistsSnapshot.data == true) {
                      // User exists in RTDB, go to HomePage
                      return HomeScreen();
                    } else {
                      // User does not exist in RTDB, show input field to get name

                      return getUserInfo(context);
                    }
                  },
                );
              } else {
                // User is not logged in, show SigninScreen
                return const SigninScreen();
              }
            }));
  }
}
