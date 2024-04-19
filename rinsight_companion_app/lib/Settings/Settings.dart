import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rinsight_companion_app/Settings/dark_mode.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 5.0,
        title: const Text('Settings', style: TextStyle(color: Color.fromARGB(255, 255, 17, 0)),),
        centerTitle: true,
      ),
            body: Consumer<UiProvider>(
        builder: (context, UiProvider notifier, child) {
          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark theme"),
                trailing: Switch(
                  value: notifier.isDark,
                  onChanged: (value)=>notifier.changeTheme()
                ),
              )
            ],
          );
        }
      ),
    );
  }
}