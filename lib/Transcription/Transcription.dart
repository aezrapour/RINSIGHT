import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  static const String websocketUrl = 'ws://127.0.0.1:8887/flutter';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initWebSocket();
  }

  void _initWebSocket() {
    channel = IOWebSocketChannel.connect(websocketUrl);
    channel.stream.listen(
      (message) {
        print('New message from server: $message');
      },
      onDone: () {
        print('WebSocket connection closed by server.');
        _reconnectWebSocket(); // Attempt to reconnect on connection close
      },
      onError: (error) {
        print('WebSocket error: $error');
        _reconnectWebSocket(); // Attempt to reconnect on error
      },
      cancelOnError: true,
    );
  }

  void _reconnectWebSocket() {
    if (mounted) {
      print('Reconnecting to WebSocket...');
      Future.delayed(Duration(seconds: 2), () {
        _initWebSocket();
      });
    }
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

  Timer? _debounceTimer;
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords + " ";
      _textController.text = _lastWords.trim();
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      print("Debounced Speech result: ${result.recognizedWords}");
      // Send the recognized words as JSON
      channel.sink.add(jsonEncode({
        "MESSAGE_TYPE_LOCAL": "FINAL_TRANSCRIPT",
        "TRANSCRIPT_TEXT": result.recognizedWords,
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Transcription'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 400,
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Speak and results will appear here",
                  filled: true,
                  // fillColor: Colors.grey.shade300,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: _speechToText.isNotListening
                  ? _startListening
                  : _stopListening,
              tooltip: 'Listen',
              backgroundColor: Theme.of(context).colorScheme.background,
              child: Icon(
                color: Colors.red,
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic),
            )
          ],
        ),
      ),
    );
  }
}
