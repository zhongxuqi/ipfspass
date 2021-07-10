import 'package:app/utils/colors.dart';
import 'package:app/utils/localization.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: ColorUtils.themeDarkColor,
        ),
        padding: EdgeInsets.fromLTRB(0.0, MediaQuery.of(context).padding.top, 0.0, 0.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0, top: 40.0),
                    child: Center(
                      child: Image.asset(
                        'images/logo_round.png',
                        height: 100.0,
                        width: 100.0,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('init_master_password'),
                      style: TextStyle(
                        color: ColorUtils.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}