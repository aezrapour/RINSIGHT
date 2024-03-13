import 'package:flutter/material.dart';
import 'package:rinsight_companion_app/Settings/settings_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RINSIGHT'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            ),
        ],
        backgroundColor: Colors.redAccent,
        leading: IconButton(
          onPressed: () {
          },
          icon: IconButton(icon: const Icon(Icons.menu),
          onPressed: () {},
          ),
        ),
      ),
    );
  }
}



