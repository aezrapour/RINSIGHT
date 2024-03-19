import 'package:flutter/material.dart';
import 'package:rinsight_companion_app/Navigation/navigation_screen.dart';
import 'package:rinsight_companion_app/Settings/settings_screen.dart';
import 'package:rinsight_companion_app/Transcription/transcription_page.dart';

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
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
        )
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Center(
                child: Wrap(
                  spacing: 20.0,
                  runSpacing: 20.0,
                  children: [
                    // Transcription Card
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TransScreen()),
                        );
                      },
                      child: buildCard('images/transcription.png', 'Transcription'),
                    ),
                    
                    // Navigation Card
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NavScreen()),
                        );
                      },
                      child: buildCard('images/navigation.png', 'Navigation'),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildCard(String imagePath, String label) {
    return SizedBox(
      width: 250.0,
      height: 250.0,
      child: Card(
        color: const Color.fromARGB(255, 32, 31, 31),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(imagePath, width: 185),
                ),
                const SizedBox(height: 10.0),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
