import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app_router/app_router.dart';
import '../../../../app_router/context_extension.dart';
import '../../../../bloc/more/more_bloc.dart';
import '../../../../bloc/more/more_state.dart';
import '../../../../bloc/settings/settings_bloc.dart';
import '../../../../bloc/settings/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Settings"),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Settings Tab"),
                const SizedBox(height: 16),
                Text(
                  "State: ${state.message}",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                BlocBuilder<MoreCubit, MoreState>(
                  builder: (ctx, moreState) {
                    return Text(
                      "More State: ${moreState.message}",
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: 128),
                TextButton(
                  onPressed: () {
                    _showSetValueDialog(
                      context,
                      (value) {
                        context.read<MoreCubit>().changeMessage(value);
                      },
                    );
                  },
                  child: const Text("Set new value to More cubit"),
                ),
                TextButton(
                  onPressed: () {
                    _showSetValueDialog(
                      context,
                      (value) {
                        context.read<SettingsCubit>().changeMessage(value);
                      },
                    );
                  },
                  child: const Text("Set new value to Settings cubit"),
                ),
                TextButton(
                  onPressed: () {
                    context.go("/more/settings/helper");
                  },
                  child: const Text("Go to Helper"),
                ),
                TextButton(
                  onPressed: () {
                    AppRouter.of(context).pop();
                  },
                  child: const Text("Pop"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSetValueDialog(
    BuildContext context,
    ValueSetter<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: onChanged,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
