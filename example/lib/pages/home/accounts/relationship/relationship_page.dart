import 'dart:math';

import 'package:example/pages/home/accounts/accounts/accounts_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app_router/interface/router.dart';

class RelationshipPage extends StatelessWidget {
  static const String name = "relationship";

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
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Relationship"),
      ),
      child: ListView.builder(
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
        PBAppNavigator.of(context).goNamed(AccountsPage.name, extra: name);
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
