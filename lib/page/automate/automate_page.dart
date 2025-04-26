import 'package:flutter/material.dart';

class AutomatePage extends StatefulWidget {
  const AutomatePage({super.key});

  @override
  State<AutomatePage> createState() => _AutomatePageState();
}

class _AutomatePageState extends State<AutomatePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Automate Page"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the Automate Page"),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
