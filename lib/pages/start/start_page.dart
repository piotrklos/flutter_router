import 'package:flutter/material.dart';

import '../../app_router/context_extension.dart';
import '../../service/user_service.dart';

class StartPage extends StatelessWidget {
  const StartPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Login Page",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Login To app"),
            const SizedBox(
              height: 16,
            ),
            TextButton(
              onPressed: () {
                UserService.isInternal = true;
                context.go("/relationship");
              },
              child: const Text("Login Internal user"),
            ),
            TextButton(
              onPressed: () {
                UserService.isInternal = false;
                context.go("/relationship/accounts");
              },
              child: const Text("Login External user"),
            ),
          ],
        ),
      ),
    );
  }
}
