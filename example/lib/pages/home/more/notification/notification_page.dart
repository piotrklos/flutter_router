import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  static const String name = "notification";
  
  const NotificationPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification"),
      ),
      body: const Center(
        child: Text("Notification Tab"),
      ),
    );
  }
}
