import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String? message;

  const ErrorPage({
    this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Error",
        ),
      ),
      body: Center(
        child: Text(message ?? "---"),
      ),
    );
  }
}
