import 'dart:async';

import 'package:app/auth.dart';
import 'package:app/utils/store.dart';
import 'package:flutter/material.dart';

import 'login.dart';


class WelcomePage extends StatefulWidget {

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 2, microseconds: 0), vsync: this);
    Timer(Duration(seconds: 2, milliseconds: 200), () async {
      final masterPassword = await StoreUtils.getMasterPassword();
      if (masterPassword.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
            LoginPage(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>
            AuthPage(),
          ),
        );
      }
      return;
    });
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        if (this == null) return;
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Opacity(
            opacity: animation.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Center(
                    child: Image.asset(
                      'images/logo_front.png',
                      height: 180.0,
                      width: 180.0,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    'IPFS Pass',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
