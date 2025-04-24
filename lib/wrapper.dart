import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/home/home.dart'; // Make sure this import path is correct
import 'screens/signin/signin.dart'; // Make sure this import path is correct

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
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
            // User is logged in, go to HomePage
            return const HomePage();
          } else {
            // User is not logged in, show SigninScreen
            return const SigninScreen();
          }
        },
      ),
    );
  }
}