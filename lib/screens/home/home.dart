import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userID = "";

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IoT Control App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hello, $userID"), // display the userID for the login user

            ElevatedButton(
                onPressed: () {
                  AuthManage().logout();
                },
                child: Text("Sign Out"))
          ],
        ),
      ),
    );
  }
}