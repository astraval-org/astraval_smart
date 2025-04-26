import 'package:astraval_smart/page/home/home_page.dart';
import 'package:astraval_smart/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget getUserInfo(BuildContext context) {
  TextEditingController nameController = TextEditingController();
  return Scaffold(
    appBar: AppBar(
      title: const Text("Complete Profile"),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Please enter your name to complete your profile",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: "Name",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
              String name = nameController.text.trim();
              if (name.isNotEmpty) {
                var userService = UserService();
                await userService.addUser(uid, name);
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                }
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    ),
  );
}
