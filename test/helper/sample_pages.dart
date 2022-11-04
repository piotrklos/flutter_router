import 'package:app_router/src/page_state.dart';
import 'package:flutter/material.dart';

Widget testScreen(BuildContext context, AppRouterPageState state) =>
    const TestScreen();

Widget startScreen(BuildContext context, AppRouterPageState state) =>
    const StartScreen();

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SamplePageScreen extends StatelessWidget {
  const SamplePageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class FamilyPage extends StatelessWidget {
  final String familyName;

  const FamilyPage(
    this.familyName, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(familyName);
  }
}

class FamilyPeronsPage extends StatelessWidget {
  final String familyName;
  final String personName;

  const FamilyPeronsPage(
    this.familyName,
    this.personName, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(familyName),
        Text(personName),
      ],
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String message;

  const ErrorScreen({
    required this.message,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message),
    );
  }
}

class TestStatefullWidget extends StatefulWidget {
  const TestStatefullWidget({Key? key}) : super(key: key);

  @override
  State<TestStatefullWidget> createState() => TestStatefullWidgetState();
}

class TestStatefullWidgetState extends State<TestStatefullWidget> {
  var counter = 0;

  void increment() {
    counter += 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
