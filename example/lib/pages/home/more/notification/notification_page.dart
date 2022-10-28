import 'package:flutter/cupertino.dart';

class NotificationPage extends StatelessWidget {
  static const String name = "notification";

  const NotificationPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Notification"),
      ),
      child: Center(
        child: Text("Notification Tab"),
      ),
    );
  }
}
