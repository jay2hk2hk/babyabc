import 'dart:io';
import 'dart:async';
//import 'package:html/dom.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter_screenutil/screenutil_init.dart';
//import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:nice_button/nice_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      allowFontScaling: false,
      builder: () => MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isShow = false;
  static List<String> listOfWord = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'];

  static List<String> listOfWordFor = ['A for Apple','B for Boy','C for Cat','D for Dog','E for Egg','F for Fish','G for Girl','H for Hand'
  ,'I for Ice-scream','J for Jet','K for Kite','L for Lamp','M for Man','N for Nose','O for Orange','P for Pen','Q for Queen','R for Rain'
  ,'S for Sugar','T for Tree','U for Umbrella','V for Van','W for Water','X for X\'mas','Y for Yellow','Z for Zoo'];
  
  /*
  A for Apple B for Boy
  C for Cat and D for Dog
  E for Egg and F for Fish
  G for Girl and H for Hand
  I for Ice-scream and J for Jet
  K for Kite and L for Lamp
  M for Man and N for Nose
  O for Orange and P for Pen
  Q for Queen and R for Rain
  S for Sugar and T for Tree
  U for Umbrella and V for Van
  W for Water and X for X'mas
  Y for Yellow and Z for Zoo
  */

  //
  FlutterTts flutterTts;
  dynamic languages;
  String language = 'en-US';
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  //String _newVoiceText;
/*
  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;
*/
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;
  //

  static int page = 1;

  @override
  void initState() 
  {
    Wakelock.enable();
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    initTts();
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
    //flutterTts.stop();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    //print("BACK BUTTON!"); // Do some stuff.
    if(!isShow)
    {
      isShow = true;
      showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Center(child:Icon(Icons.exit_to_app_sharp)),
                //content: Center(child:Icon(Icons.exit_to_app_sharp)),
                actions: [
                  CupertinoDialogAction(
                    child: Icon(Icons.check),
                    onPressed:  () => exit(0),
                  ),
                  CupertinoDialogAction(
                    child: Icon(Icons.clear),
                    onPressed: () {
                      isShow = false;
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          
    }
    
    return true;
  }

  initTts() {
    flutterTts = FlutterTts();

    /*_getLanguages();

    if (isAndroid) {
      _getEngines();
    }
*/
    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        //ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        //ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        //ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          //ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          //ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        //ttsState = TtsState.stopped;
      });
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak(String _newVoiceText) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setLanguage(language);

    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(_newVoiceText);
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    //if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    //if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void onPressNext()
  {
    if(page<5)
    {
      setState(() {
        page+=1;
      });
    }
      
  }
  void onPressPre()
  {
    if(page>1)
    {
      setState(() {
        page-=1;
      });
    }
  }

  List<Widget> getPageABC()
  {
    List<Widget> temp = new List<Widget>();
    if(page!=5)
    {
      for(int i=(page*6)-6;i<page*6;i+=2)
      {
        String t1 = listOfWord[i];
        String t2 = listOfWord[i+1];
          temp.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                NiceButton(
                width: ScreenUtil().setSp(150),
                elevation: 10.0,
                radius: ScreenUtil().setSp(52.0),
                text: "\n$t1\n",
                background: Colors.blue,
                onPressed: () {
                    _speak(listOfWordFor[i]);
                    },
                ),
                NiceButton(
                width: ScreenUtil().setSp(150),
                elevation: 10.0,
                radius: ScreenUtil().setSp(52.0),
                text: "\n$t2\n",
                background: Colors.blue,
                onPressed: () {
                    _speak(listOfWordFor[i+1]);
                    },
                ),
              ],
            )
          );
          temp.add(SizedBox(height: 10));
        
      }     
    }
    else
    {
      String t1 = listOfWord[24];
        String t2 = listOfWord[25];
          temp.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                NiceButton(
                width: ScreenUtil().setSp(150),
                elevation: 10.0,
                radius: ScreenUtil().setSp(52.0),
                text: "\n$t1\n",
                background: Colors.blue,
                onPressed: () {
                    _speak(listOfWordFor[24]);
                    },
                ),
                NiceButton(
                width: ScreenUtil().setSp(150),
                elevation: 10.0,
                radius: ScreenUtil().setSp(52.0),
                text: "\n$t2\n",
                background: Colors.blue,
                onPressed: () {
                    _speak(listOfWordFor[25]);
                    },
                ),
              ],
            )
          );
          temp.add(SizedBox(height: 10));
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      /*appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),*/
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: getPageABC(),
        ),
      ),
      floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
      floatingActionButton: 
      Padding(
            padding: /*const EdgeInsets.all(40.0),*/const EdgeInsets.fromLTRB(38.0,8.0,8.0,32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
      FloatingActionButton(
        onPressed: onPressPre,
        //tooltip: 'Increment',
        child: Icon(Icons.arrow_left),
      ), 

      FloatingActionButton(
        onPressed: onPressNext,
        //tooltip: 'Increment',
        child: Icon(Icons.arrow_right),
      ),
              ],
    ),), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
