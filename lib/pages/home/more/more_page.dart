import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app_router/context_extension.dart';
import '../../../bloc/more/more_bloc.dart';
import '../../../bloc/more/more_state.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MoreCubit, MoreState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("More"),
          ),
          body: ListView(
            primary: true,
            children: [
              Container(
                height: 200,
                color: Colors.red,
              ),
              const Text(
                "More Tab",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "State: ${state.message}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  context.go("/more/notification");
                },
                child: const Text("Notification"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go("/more/settings");
                },
                child: const Text("Settings"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.go("/");
                },
                child: const Text("Log out"),
              ),
              Container(
                height: 200,
                color: Colors.red,
              ),
              Container(
                height: 200,
                color: Colors.yellow,
              ),
              Container(
                height: 200,
                color: Colors.green,
              ),
              Container(
                height: 200,
                color: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }
}
