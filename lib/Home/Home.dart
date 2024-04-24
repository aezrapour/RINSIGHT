// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rinsight_companion_app/Models/modules_repo.dart';
import 'package:rinsight_companion_app/Navigation/Navigation.dart';
import 'package:rinsight_companion_app/Settings/Settings.dart';
import 'package:rinsight_companion_app/TextToSpeech/TextToSpeech.dart';
import 'package:rinsight_companion_app/Transcription/Transcription.dart';
import 'package:rinsight_companion_app/Translation/translation.dart';
import 'package:rinsight_companion_app/Models/modules_repo.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static var listModules = 
  [
    Modules
    (
      'images/Translate.png',
      "Translation", 
      "View live, fast, on-device translation of your favorite language on your smart glasses and the app.", 
      ),
    Modules
    (
     
      'images/Transcription.png',
      'Transcription', 
       "View live, fast, on-device transcription right on your smart glasses and on the app.", 
      
    ),
    Modules
    (
      'images/TextToSpeech.png',
      'Text To Speech', 
      "Use the quick, accurate, on-app text to speech functionality with custom pitch, and speech rate controls.", 
      
    ),
    Modules
    (
      'images/NavigationIcon.png',
      'Navigation', 
      "Simple and lightning fast street navigation provided to your through your R-INSIGHT glasses and on the app.", 
    ),
  ];

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        elevation: 1.0,
        shadowColor: Colors.white.withOpacity(0.1),
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 5.0,
        actions: <Widget>
        [
          IconButton
          (
            icon: Icon(Icons.settings),
            onPressed: () 
            {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          )
        ], 
          title: const Text
          (
            'R-INSIGHT',
            style:TextStyle(color: Color.fromARGB(255, 255, 17, 0), fontWeight: FontWeight.bold, fontFamily: 'CupertinoSystemText'),
          ),
          centerTitle: true,
      ),
      body: Padding
      (
        padding: const EdgeInsets.all(16.0),
        child: GridView
        (
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount
          (
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 10/16,
          ), 
          children: 
          [
            Material(
              elevation: 3,
              shape: RoundedRectangleBorder
              (
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell
              (
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute<void>(builder: (BuildContext context) => Translation())
                    );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container
                (
                  child: Padding
                  (
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column
                    (
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: 
                      [
                        Image.asset(listModules[0].modulePicture,scale: 4,width: 100,),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row
                          (
                            children: 
                            [
                              Container
                              (
                                decoration: BoxDecoration
                                (
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  listModules[0].moduleName,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 19,
                                  ),
                                  ),
                          ),
                          SizedBox(height: 15,),
                          Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  textAlign: TextAlign.center,
                                  listModules[0].moduleDescription,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 11,
                                  ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Material(
              elevation: 3,
              shape: RoundedRectangleBorder
              (
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell
              (
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute<void>(builder: (BuildContext context) => SpeechToTextPage())
                    );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container
                (
                  child: Padding
                  (
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column
                    (
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: 
                      [
                          Image.asset(listModules[1].modulePicture,scale: 3,width: 150,),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          child: Row
                          (
                            children: 
                            [
                              Container
                              (
                                decoration: BoxDecoration
                                (
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  listModules[1].moduleName,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 19,
                                  ),
                                  ),
                          ),
                          SizedBox(height: 15,),
                          Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  textAlign: TextAlign.center,
                                  listModules[1].moduleDescription,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 11,
                                  ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Material(
              elevation: 3,
              shape: RoundedRectangleBorder
              (
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell
              (
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute<void>(builder: (BuildContext context) => TextToSpeech())
                    );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding
                (
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: Column
                  (
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: 
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Image.asset(listModules[2].modulePicture, width: 100,scale: 3,),
                      ),
                      Padding
                      (
                        padding: const EdgeInsets.all(6),
                        child: Row
                        (
                          children: 
                          [
                            Container
                            (
                              decoration: BoxDecoration
                              (
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding
                      (
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text
                              (
                                listModules[2].moduleName,
                                style: TextStyle
                                (
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Helvetica-Neue',
                                  fontSize: 19,
                                ),
                                ),
                        ),
                        SizedBox(height: 15,),
                        Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text
                              (
                                textAlign: TextAlign.center,
                                listModules[2].moduleDescription,
                                style: TextStyle
                                (
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Helvetica-Neue',
                                  fontSize: 11,
                                  
                                ),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            Material(
              elevation: 3,
              shape: RoundedRectangleBorder
              (
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell
              (
                onTap: ()
                {
                  Navigator.push
                  (
                    context, 
                    MaterialPageRoute<void>(builder: (BuildContext context) => NavScreen())
                    );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container
                (
                  child: Padding
                  (
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column
                    (
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: 
                      [
                        Image.asset(listModules[3].modulePicture, width: 100, scale: 4,),
                        Padding
                        (
                          padding: const EdgeInsets.all(5.0),
                          child: Row
                          (
                            children: 
                            [
                              Container
                              (
                                decoration: BoxDecoration
                                (
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding
                        (
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  listModules[3].moduleName,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 19,
                                  ),
                                  ),
                          ),
                          SizedBox(height: 15,),
                          Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text
                                (
                                  textAlign: TextAlign.center,
                                  listModules[3].moduleDescription,
                                  style: TextStyle
                                  (
                                    fontWeight: FontWeight.w300,
                                    fontFamily: 'Helvetica-Neue',
                                    fontSize: 11,
                                    
                                  ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}