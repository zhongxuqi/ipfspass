import 'package:app/utils/localization.dart';
import 'package:flutter/material.dart';
import 'db/data.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/colors.dart';
import 'welcome.dart';

void main() {
  runApp(MyApp());
  InitDB();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPFS Pass',
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
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('zh','CH'),
      ],
    );
  }
}

class MainPage extends StatefulWidget {

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.themeDarkColor,
      body: Padding(
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Text("Main Page", 
          style: TextStyle(
            color: ColorUtils.white,
          ),
        ),
      ),
    );
  }
}
