import 'package:app/utils/localization.dart';
import 'package:flutter/material.dart';
import 'db/data.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'utils/colors.dart';
import 'utils/iconfonts.dart';
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
  var keywordCtl = TextEditingController();
  var focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.themeDarkColor,
      body: Padding(
        padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: [
            Container(
              height: 50.0,
              child: Container(
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Icon(
                          IconFonts.bars1,
                          size: 19.0,
                          color: ColorUtils.green,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorUtils.themeLightColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(4.0),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 6.0),
                              child: Icon(
                                IconFonts.search1,
                                color: ColorUtils.white,
                                size: 20.0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                child: TextField(
                                  controller: keywordCtl,
                                  scrollPadding: EdgeInsets.all(0),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      gapPadding: 0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 0,
                                        style: BorderStyle.none
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      gapPadding: 0,
                                      borderSide: BorderSide(
                                        color: Colors.transparent,
                                        width: 0,
                                        style: BorderStyle.none
                                      ),
                                    ),
                                    fillColor: Colors.transparent,
                                    hintText: AppLocalizations.of(context).getLanguageText('keyword_hint'),
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 15.0,
                                      textBaseline: TextBaseline.alphabetic,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),
                              ),
                            ),
                            keywordCtl.text == "" ? Container() : 
                            GestureDetector(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                                height: 50.0,
                                color: Colors.transparent,
                                child: Icon(
                                  IconFonts.close,
                                  color: Colors.grey,
                                  size: 15.0,
                                ),
                              ),
                              onTap: () {
                                keywordCtl.text = '';
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        
                      },
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: Icon(
                          IconFonts.sort,
                          size: 19.0,
                          color: ColorUtils.green,
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
