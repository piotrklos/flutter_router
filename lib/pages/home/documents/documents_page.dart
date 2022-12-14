import 'package:flutter/material.dart';

import '../../../app_router/context_extension.dart';
import '../../shared/shared_page.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Documents"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Documents Tab"),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _showModal(context, false);
              },
              child: const Text("Show Bottom Sheet (useRootNavigator = false)"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _showModal(context, true);
              },
              child: const Text("Show Bottom Sheet (useRootNavigator = true)"),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.push(
                  "/shared",
                  extra: SharedObject("Sample message from documents"),
                );
              },
              child: const Text("Go to shared page"),
            ),
          ],
        ),
      ),
    );
  }

  void _showModal(BuildContext context, bool useRootNavigator) {
    showModalBottomSheet(
      useRootNavigator: useRootNavigator,
      context: context,
      builder: (ctx) {
        return Container(
          height: 200,
          color: Colors.amber,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Modal BottomSheet'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
