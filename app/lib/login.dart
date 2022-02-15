import 'dart:convert';

import 'package:app/utils/colors.dart';
import 'package:app/utils/content.dart';
import 'package:app/utils/localization.dart';
import 'package:app/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'components/LoginFormItem.dart';
import 'main.dart';
import 'utils/iconfonts.dart';
import 'dart:io';
import 'db/data.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final registerMasterPasswordCtl = TextEditingController();
  String registerMasterPasswordErr = '';
  final registerReMasterPasswordCtl = TextEditingController();
  String registerReMasterPasswordErr = '';

  void login() async {
    var hasErr = false;
    if (registerMasterPasswordCtl.text.isEmpty) {
      registerMasterPasswordErr = AppLocalizations.of(context).getLanguageText('required');
      hasErr = true;
    }
    if (registerReMasterPasswordCtl.text.isEmpty) {
      registerReMasterPasswordErr = AppLocalizations.of(context).getLanguageText('required');
      hasErr = true;
    }
    if (registerMasterPasswordCtl.text.isNotEmpty && registerReMasterPasswordCtl.text.isNotEmpty && registerMasterPasswordCtl.text != registerReMasterPasswordCtl.text) {
      registerReMasterPasswordErr = AppLocalizations.of(context).getLanguageText('repeat_error');
      hasErr = true;
    }
    if (hasErr) {
      setState(() {});
      return;
    }
    await StoreUtils.setMasterPassword(registerMasterPasswordCtl.text);
    await getDataModel().deleteAllContentInfo();
    goMainPage();
  }

  void recoverDataFromBackupFile() async {
    await getDataModel().deleteAllContentInfo();
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if(result != null) {
      File file = File(result.files.single.path);
      var contentBackup = ContentBackup.fromMap(json.decode(utf8.decode(file.readAsBytesSync())));
      StoreUtils.setRawMasterPassword(contentBackup.encryptedMasterPassword);
      for (var contentInfo in contentBackup.contents) {
        await getDataModel().upsertContentInfo(contentInfo, (id) {});
      }
      goMainPage();
    } else {
      // User canceled the picker
    }
  }

  void goMainPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>
        MainPage(),
      ),
    );
  }

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
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: Container(
                      width: 300,
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
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: Container(
                      width: 300,
                      child: LoginFormItem(
                        iconData: IconFonts.lock,
                        hintText: AppLocalizations.of(context).getLanguageText('register_remasterpassword_hint'),
                        textEditCtl: registerReMasterPasswordCtl,
                        onChanged: (newText) {
                          setState(() {
                            registerReMasterPasswordErr = '';
                          });
                        },
                        errText: registerReMasterPasswordErr,
                        obscureText: true,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      child: Container(
                        width: 300,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: ColorUtils.blue,
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).getLanguageText('init_master_password'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: login,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      child: Container(
                        width: 300,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        decoration: BoxDecoration(
                          color: ColorUtils.green,
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).getLanguageText('recover_data_from_backup_file'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: recoverDataFromBackupFile,
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