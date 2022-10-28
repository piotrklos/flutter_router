import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharedObject {
  final String message;

  SharedObject(this.message);
}

class SharedPage extends StatelessWidget {
  static const name = "shared";
  final SharedObject? sharedObject;

  const SharedPage({
    required this.sharedObject,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Shared"),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Share Page"),
            const SizedBox(height: 16),
            Text(sharedObject?.message ?? "-----"),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop("test");
                // AppRouter.of(context).pop("Przyklad");
              },
              child: const Text("Pop"),
            ),
          ],
        ),
      ),
    );
  }
}
