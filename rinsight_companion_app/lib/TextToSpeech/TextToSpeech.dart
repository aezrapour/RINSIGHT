import 'package:flutter/material.dart';
import 'package:rinsight_companion_app/Home/homescreen.dart';


class TextToSpeech extends StatelessWidget {
  const TextToSpeech({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text To Speech'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
          },
          child: const Text('Go back!'),
          
        ),
      ),
    );
  }
}