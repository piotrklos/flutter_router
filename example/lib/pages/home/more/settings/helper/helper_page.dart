import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app_router/interface/router.dart';
import '../../../../../bloc/helper/helper_bloc.dart';
import '../../../../../bloc/helper/helper_state.dart';
import '../../../../../bloc/more/more_bloc.dart';
import '../../../../../bloc/more/more_state.dart';
import '../../../../../bloc/settings/settings_bloc.dart';
import '../../../../../bloc/settings/settings_state.dart';

class HelperPage extends StatelessWidget {
  static const name = "helper";
  
  final String? initText;
  const HelperPage({
    this.initText,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelperCubit, HelperState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Helper Settings"),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Helper Page"),
                const SizedBox(height: 16),
                Text(
                  "Helper State: ${state.message}",
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
                const SizedBox(height: 16),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (ctx, settingsState) {
                    return Text(
                      "Settings State: ${settingsState.message}",
                      textAlign: TextAlign.center,
                    );
                  },
                ),
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
                    _showSetValueDialog(
                      context,
                      (value) {
                        context.read<HelperCubit>().changeMessage(value);
                      },
                    );
                  },
                  child: const Text("Set new value to Helper cubit"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop("Wartosc z helpera");
                  },
                  child: const Text("Go back"),
                ),
                TextButton(
                  onPressed: () {
                    PBAppNavigator.of(context).pop();
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
