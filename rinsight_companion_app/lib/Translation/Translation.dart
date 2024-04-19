// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rinsight_companion_app/Home/Home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Translation extends StatefulWidget {
  const Translation({super.key});

  @override
  State<Translation> createState() => _TranslationState();
}

class _TranslationState extends State<Translation> {

  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  late WebSocketChannel channel;
  static const String websocketUrl = 'ws://127.0.0.1:8887/flutter';
  var languages = ["English", "Spanish", "French", "German", "Portuguese", "Japanese", "Korean", "Hindi"];
  var langRequest = "From";
  var langResponse = "To";
  var output = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initWebSocket();
  }

  String getLanguageCode (String language)
  {
    if (language == "English")
    {
      return "en";
    }
    else if (language == "Spanish")
    {
      return "es";
    }
    else if (language == "French")
    {
      return "fr";
    }
    else if (language == "German")
    {
      return "de";
    }
    else if (language == "Portuguese")
    {
      return "pt";
    }
    else if (language == "Japanese")
    {
      return "ja";
    }
    else if (language == "Korean")
    {
      return "ko";
    }
    else if (language == "Hindi")
    {
      return "hi";
    }
    return "--";
  }

  void translate(String src, String dest, String input) async
  {
    GoogleTranslator translator = new GoogleTranslator();
    var translation = await translator.translate(input, from: src, to: dest);
    setState(() {
      output = translation.text.toString();
    });
    if (src == "--" || dest == "--")
    {
      setState(() {
        output = "Failed to translate";
      });
    }
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
      localeId: getLanguageCode(langRequest), // Correct the locale ID
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
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      backgroundColor: Colors.white,
      appBar: AppBar
      (
        elevation: 5.0,
        shadowColor: Colors.white.withOpacity(0.2),
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 5.0,
        backgroundColor: Colors.white,
        leading: IconButton
          (
            onPressed: () 
            {
              Navigator.pop(context);
            }, 
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text
          (
            'Translate',
            style:TextStyle(color: Colors.red),
          ),
          centerTitle: true,
      ),
      body: Center
      (  
        child: SingleChildScrollView
        (
          child: Column
          (
            mainAxisAlignment: MainAxisAlignment.center,
            children: 
            [
              SizedBox(height: 50.0,),
              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: 
                [
                  Container
                  (
                    width: 300,
                    decoration: BoxDecoration
                    (
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6))
                      ),
                    child: DropdownButton
                    (
                      underline: Container
                      (
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(right: 20, left: 20),
                      menuMaxHeight: 200.0,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      isExpanded: true,
                      focusColor: Colors.white,
                      iconDisabledColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      hint: Text
                      (
                        langRequest,
                        style: TextStyle(color: Colors.black),
                      ),
                      dropdownColor: Colors.white,
                      icon: Icon(Icons.language, color: Colors.red),
                      items: languages.map((String dropDownLang)
                      {
                        return DropdownMenuItem(value: dropDownLang,child: Text(dropDownLang));
                      }).toList(),
                      onChanged:(String? value) 
                      {
                        setState
                        (() 
                        {
                          langRequest = value!;
                        });
                      },
                    
                    ),
                  ),
                  SizedBox(width: 40.0,height: 30,),
                  Icon(Icons.arrow_downward_rounded, color: Colors.black,size: 40,),
                  SizedBox(width: 40.0,height: 30,),
                  SizedBox(
                    width: 300.0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          decoration: BoxDecoration
                          (
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(width: 0.5, color: Colors.grey.withOpacity(0.6))
                          ),
                          child: DropdownButton(
                            underline: Container
                            (
                            color: Colors.white,
                            ),
                            padding: EdgeInsets.only(right: 20, left: 20),
                            menuMaxHeight: 200.0,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            focusColor: Colors.white,
                            iconDisabledColor: Colors.white,
                            iconEnabledColor: Colors.white,
                            isExpanded: true,
                          
                            hint: Text(
                              langResponse,
                              style: TextStyle(color: Colors.black),
                            ),
                            dropdownColor: Colors.white,
                            icon: Icon(Icons.language,color: Colors.red,),
                            items: languages.map((String dropDownLang)
                            {
                              return DropdownMenuItem(value: dropDownLang,child: Text(dropDownLang), );
                            }).toList(),
                            onChanged:(String? res) 
                            {
                              setState(() {
                                langResponse = res!;
                              });
                            },
                          
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 50,),
              SizedBox
              (
                width: 400,
                child: TextFormField
                (
                  controller: _textController,
                  validator: (value)
                  {
                    if (value == null || value.isEmpty)
                    {
                      return "Please enter speak to translate.";
                    }
                    return null;
                  },
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration
                  (
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.07),
                    border: OutlineInputBorder
                    (
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Icon(Icons.arrow_downward_rounded, color: Colors.black,size: 40,),
              SizedBox(height: 20),
              Container
              (
                padding:EdgeInsets.all(20),
                width: 400,
                decoration: BoxDecoration
                (
                  color: Colors.grey.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(20),
                  ),
                child: Container
                (
                  child: SelectableText
                  (
                    minLines: 2,
                    maxLines: 5,
                    textAlign: TextAlign.start,
                    "$output",
                    style: TextStyle
                    (
                      color: Colors.black,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Column
              (
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: 
                [
                  FloatingActionButton
                  (
                    onPressed: _speechToText.isNotListening
                        ? _startListening
                        : _stopListening,
                    tooltip: 'Listen',
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                  ),
                  SizedBox(height: 40.0,),
                  ElevatedButton
                  (
                    style: ButtonStyle( 
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white)
                    ),
                    onPressed: ()
                    {
                      translate(getLanguageCode(langRequest), getLanguageCode(langResponse),_textController.text.toString());
                    }, 
                    child: Text("Translate"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}