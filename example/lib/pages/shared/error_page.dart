import 'package:flutter/cupertino.dart';

class ErrorPage extends StatelessWidget {
  final String? message;

  const ErrorPage({
    this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          "Error",
        ),
      ),
      child: Center(
        child: Text(message ?? "---"),
      ),
    );
  }
}
