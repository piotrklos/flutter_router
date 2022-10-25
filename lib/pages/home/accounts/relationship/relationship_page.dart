import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app_router/context_extension.dart';

class RelationshipPage extends StatelessWidget {
  static const List<String> _relationship = [
    "Kowlaski",
    "Nowax",
    "Matejkox",
  ];

  const RelationshipPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Relationship"),
      ),
      body: ListView.builder(
        itemBuilder: (ctx, index) {
          return _relationshipItem(context, _relationship[index]);
        },
        itemCount: _relationship.length,
      ),
    );
  }

  Widget _relationshipItem(BuildContext context, String name) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        context.go("/relationship/accounts", extra: name);
      },
      child: Container(
        color: Colors.grey
            .withGreen(Random.secure().nextInt(255))
            .withBlue(Random.secure().nextInt(255)),
        height: 75,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(name),
        ),
      ),
    );
  }
}
