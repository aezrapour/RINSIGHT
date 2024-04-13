import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rinsight_companion_app/Home/homescreen.dart';

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({Key? key}) : super(key: key);

  @override
  _SpeechToTextPage createState() => _SpeechToTextPage();
}

class _SpeechToTextPage extends State<SpeechToTextPage> {
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    channel = IOWebSocketChannel.connect('ws://127.0.0.1:8887');
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _initSpeech() async {
    final hasPermission = await _checkPermission();
    if (hasPermission) {
      _speechEnabled = await _speechToText.initialize(
          onError: (error) => print('Error initializing speech: $error'),
          onStatus: (status) => print('Speech status: $status'));
      if (_speechEnabled) {
        print("Speech initialization successful");
      } else {
        print("Speech initialization failed");
      }
    } else {
      print("Microphone permission not granted");
    }
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return true; // Permission is already granted
    } else {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        return true; // Permission granted after requesting
      } else {
        // Handle the case where the user denies the permission
        if (status.isPermanentlyDenied) {
          // Open app settings if permission is permanently denied
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Microphone Permission"),
              content: Text(
                  "This app needs microphone access to function. Please enable it in app settings."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    openAppSettings(); // Directs the user to the app settings.
                  },
                  child: Text("Open Settings"),
                ),
              ],
            ),
          );
        }
        return false;
      }
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      print("Speech not initialized");
      return;
    }
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: "en_US", // Correct the locale ID
      cancelOnError: true,
      partialResults: true,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords + " ";
      _textController.text = _lastWords.trim();
    });
    print("Speech result: ${result.recognizedWords}");
    // Send the recognized words as JSON
    channel.sink.add('{"text": "${result.recognizedWords}"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: const Text('Go back!'),
            ),
            TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Speak and results will appear here",
                filled: true,
                fillColor: Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              tooltip: 'Listen',
              backgroundColor: Colors.blueGrey,
              child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            )
          ],
        ),
      ),
    );
  }
}
