import 'package:app/utils/colors.dart';
import 'package:app/utils/store.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'components/AlertDialog.dart';
import 'components/Toast.dart';
import 'login.dart';
import 'main.dart';
import 'utils/iconfonts.dart';
import 'utils/localization.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthPage extends StatefulWidget {
  final bool isLock;

  AuthPage({Key key, @required this.isLock}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  var masterPasswordCtl = TextEditingController();

  @override
    void initState() {
      super.initState();
      _authenticate();
    }

  void unlock() {
    if (widget.isLock) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>
          MainPage(),
        ),
      );
    }
  }

  Future<Null> _authenticate() async {
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: AppLocalizations.of(context).getLanguageText('fingerprint_hint'),
        useErrorDialogs: true,
        stickyAuth: false,
        biometricOnly: true);
    } on PlatformException catch (e) {
      print(e);
      return;
    }
    if (!mounted) return;

    if (authenticated) {
      unlock();
    }
  }

  Future<bool> _onWillPop(){
    if (Platform.isAndroid) {
      SystemNavigator.pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: ColorUtils.themeDarkColor,
        body: Padding(
          padding: new EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverList(
                delegate: new SliverChildListDelegate(
                  <Widget>[
                    Row(
                      children: <Widget>[
                        InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            child: Icon(
                              IconFonts.arrowLeft,
                              size: 24.0,
                              color: const Color(0xff667eea),
                            ),
                          ),
                          onTap: () async {
                            showAlertDialog(context, AppLocalizations.of(context).getLanguageText('clear_data_alert'),
                              callback: () async {
                                StoreUtils.setMasterPassword("");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                    LoginPage(),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
                      child: Center(
                        child: Image.asset(
                          'images/logo_round.png',
                          height: 100.0,
                          width: 100.0,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(left: 30.0, right: 5.0),
                            decoration: BoxDecoration(
                              color: ColorUtils.themeLightColor,
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  height: 40.0,
                                  width: 40.0,
                                  child: Icon(
                                    IconFonts.lock,
                                    size: 22.0,
                                    color: ColorUtils.white,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 40,
                                    child: TextField(
                                      controller: masterPasswordCtl,
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
                                        hintText: AppLocalizations.of(context).getLanguageText('input_masterpassword_hint'),
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
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5.0, right: 30.0),
                          decoration: BoxDecoration(
                            color: ColorUtils.blue,
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),
                          child: InkWell(
                            child: Container(
                              height: 36.0,
                              width: 36.0,
                              alignment: Alignment.center,
                              child: Icon(
                                IconFonts.arrowRight,
                                size: 15.0,
                                color: ColorUtils.white,
                              ),
                            ),
                            onTap: () async {
                              var masterPassword = masterPasswordCtl.text;
                              if (masterPassword != await StoreUtils.getMasterPassword()) {
                                showErrorToast(AppLocalizations.of(context).getLanguageText('wrong_masterpassword'));
                                return;
                              }
                              unlock();
                            },
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 40),
                        alignment: Alignment.center,
                        child: Icon(
                          IconFonts.fingerprint,
                          size: 40.0,
                          color: ColorUtils.white,
                        ),
                      ),
                      onTap: () {
                        _authenticate();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}