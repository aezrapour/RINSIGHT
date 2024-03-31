import 'package:flutter/material.dart';

class TransScreen extends StatefulWidget {
  const TransScreen({Key? key}) : super(key: key);

  @override
  _TransScreenState createState() => _TransScreenState();
}

class _TransScreenState extends State<TransScreen> {
  // Hardcoded list of transcriptions for demonstration
  final List<String> _transcriptions = [
    "Hello, how are you today?",
    "I'm fine, thank you!",
    "Isn't the weather lovely today?",
    "Yes, it's perfect for a walk in the park.",
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcriptions'),
        centerTitle: true,
      ),
      body: Center(
        child: ListView.builder(
              itemCount: _transcriptions.length,
              itemBuilder: (context, index) {
                return ListTile(
              leading: Icon(Icons.mic, color: Colors.blueAccent),
              title: Text(_transcriptions[index]),
            // Customize each ListTile as needed
          );
        },
      
      ),
      
      ),
      
      
    );
  }
}
