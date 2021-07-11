import 'package:app/utils/colors.dart';
import 'package:app/utils/localization.dart';
import 'package:flutter/material.dart';

import 'components/LoginFormItem.dart';
import 'utils/iconfonts.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final registerMasterPasswordCtl = TextEditingController();
  String registerMasterPasswordErr = '';
  final registerReMasterPasswordCtl = TextEditingController();
  String registerReMasterPasswordErr = '';

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
                      AppLocalizations.of(context).getLanguageText('master_password'),
                      style: TextStyle(
                        color: ColorUtils.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 10.0),
                    child: LoginFormItem(
                      iconData: IconFonts.lock,
                      hintText: AppLocalizations.of(context).getLanguageText('register_masterpassword_hint'),
                      textEditCtl: registerMasterPasswordCtl,
                      onChanged: (newText) {
                        setState(() {
                          registerMasterPasswordErr = '';
                        });
                      },
                      errText: registerMasterPasswordErr,
                      obscureText: true,
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