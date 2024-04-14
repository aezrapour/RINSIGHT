// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rinsight_companion_app/Home/homescreen.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:rinsight_companion_app/Settings/settings_screen.dart';


class TextToSpeech extends StatefulWidget {
  const TextToSpeech({super.key});

  @override
  State<TextToSpeech> createState() => _TextToSpeechState();
}

enum TtsState { playing, stopped, paused, continued }

class _TextToSpeechState extends State<TextToSpeech> {
  
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    initTts();
  }

  dynamic initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar
      (
          title: const Text(
            'Text To Speech',
            style:TextStyle(color: Colors.white),
            ),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ],
          backgroundColor: Colors.redAccent,
          ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              _inputSection(),
              ttsButtons(),
              _engineSection(),
              _futureBuilder(),
              _buildSliders(),
              goBackButton(),
              if (isAndroid) _getMaxSpeechInputLengthSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data as List<dynamic>);
            } else if (snapshot.hasError) {
              return Text('Error loading engines...');
            } else
              return Text('Loading engines...');
          });
    } else
      return Container(width: 0, height: 0);
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return languageDropDown(snapshot.data as List<dynamic>);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() => Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(left: 25.0,right: 25.0, top: 25.0),
      padding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
      decoration:
        BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(width: 1, color: Colors.grey)
          ),
      child: TextField(
        
        enableSuggestions: true,
        showCursor: true,
        maxLines: 11,
        minLines: 7,
        onChanged: (String value) 
        {
          _onChange(value);
        },
      )
      );

  Widget ttsButtons() {
    return Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(Color.fromARGB(255, 16, 25, 148), Color.fromARGB(255, 47, 58, 223), Icons.play_arrow,
              'SPEAK', _speak),
          _buildButtonColumn(
              Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop),
          _buildButtonColumn(
              Colors.black, Colors.black, Icons.pause, 'PAUSE', _pause),
        ],
      ),
    );
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => Container(
        padding: EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          dropdownColor: const Color.fromARGB(255, 76, 76, 76),
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  Widget languageDropDown(List<dynamic> languages) => Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          menuMaxHeight: 400.0,
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _getMaxSpeechInputLengthSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('Get max speech input length'),
          onPressed: () async {
            _inputLength = await flutterTts.getMaxSpeechInputLength;
            setState(() {});
          },
        ),
        Text("$_inputLength characters"),
      ],
    );
  }

  Widget _buildSliders() {
    return Column(
      children: [volumeSlider(), pitchSlider(), rateSlider()],
    );
  }

  Widget volumeSlider() {
    return Column(
      children: [
        Text("Volume"),
        Slider(
        value: volume,
        onChanged: (newVolume) {
          setState(() => volume = newVolume);
        },
        min: 0.0,
        max: 1.0,
        divisions: 20,
        activeColor: Color.fromARGB(255, 237, 76, 26),
        label: "$volume")
      ],
    );
  }

  Widget pitchSlider() {
    return Column(
      children: [
        Text("Pitch"),
        Slider(
          value: pitch,
          onChanged: (newPitch) {
            setState(() => pitch = newPitch);
          },
          min: 0.5,
          max: 2.0,
          divisions: 20,
          label: "$pitch",
          activeColor: Color.fromARGB(255, 237, 76, 26),
        ),
      ],
    );
  }

  Widget rateSlider() {
    return Column(
      children: [
        Text("Speech Rate"),
        Slider(
          value: rate,
          onChanged: (newRate) {
            setState(() => rate = newRate);
          },
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: "$rate",
          activeColor: Color.fromARGB(255, 237, 76, 26),
        ),
      ],
    );
  }
  Widget goBackButton() 
  {
    return ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  barrierDismissible: true,
                  builder: (context) => const HomeScreen()),
              );
          },
          child: const Text(
            'Return',
            style: TextStyle(color: Colors.black),
            )
        );
  }
}