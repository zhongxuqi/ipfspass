import 'package:flutter/material.dart';
import 'utils/localization.dart';
import 'utils/store.dart';
import 'dart:async';
import 'package:numberpicker/numberpicker.dart';
import 'components/topbar.dart';
import 'utils/iconfonts.dart';
import 'utils/colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int lockTimeout = 30;
  bool autoUploadIPFS = false;
  bool autoBackupContent = false;

  @override
  void initState() {
    super.initState();
    initData();
  }

  void initData() async {
    lockTimeout = await StoreUtils.getLockScreen();
    autoUploadIPFS = await StoreUtils.getAutoUploadIPFS();
    autoBackupContent = await StoreUtils.getAutoBackupContent();
    setState(() {});
  }

  Future<Null> showTimeoutDailog() async {
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return ReAuthDialog(lockTimeout: lockTimeout, callback: initData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorUtils.themeDarkColor,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[
                  TopBar(
                    title: AppLocalizations.of(context).getLanguageText('settings'),
                  ),
                  GestureDetector(
                    child: Card(
                      elevation: 1.0,
                      color: ColorUtils.themeLightColor,
                      margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Text(
                                AppLocalizations.of(context).getLanguageText('reauth_timeout'),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              "${lockTimeout} ${AppLocalizations.of(context).getLanguageText('second')}",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Icon(
                                IconFonts.arrowRight,
                                size: 15.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: () {
                      showTimeoutDailog();
                    },
                  ),
                  Card(
                    elevation: 1.0,
                    color: ColorUtils.themeLightColor,
                    margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              AppLocalizations.of(context).getLanguageText('auto_upload_ipfs'),
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Switch(
                            activeColor: ColorUtils.green,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: autoUploadIPFS, 
                            onChanged: (newValue) async {
                              await StoreUtils.setAutoUploadIPFS(newValue);
                              autoUploadIPFS = newValue;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 1.0,
                    color: ColorUtils.themeLightColor,
                    margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              AppLocalizations.of(context).getLanguageText('auto_backup_content'),
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Switch(
                            activeColor: ColorUtils.green,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: autoBackupContent,
                            onChanged: (newValue) async {
                              await StoreUtils.setAutoBackupContent(newValue);
                              autoBackupContent = newValue;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReAuthDialog extends StatefulWidget {
  final int lockTimeout;
  final VoidCallback callback;
  
  ReAuthDialog({Key key, @required this.lockTimeout, @required this.callback}):super(key: key);

  @override
  ReAuthDialogState createState() => new ReAuthDialogState();
}

class ReAuthDialogState extends State<ReAuthDialog> {
  int _lockTimeout = 30;

  @override
  void initState() {
    super.initState();
    _lockTimeout = widget.lockTimeout;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      backgroundColor: ColorUtils.themeLightColor,
      children: <Widget>[
        Container(
          child: Text(
            AppLocalizations.of(context).getLanguageText('reauth_timeout'),
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: ColorUtils.textColor,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NumberPicker(
              value: _lockTimeout,
              minValue: 0,
              maxValue: 30,
              textStyle: TextStyle(
                color: ColorUtils.grey,
                fontSize: 14,
              ),
              selectedTextStyle: TextStyle(
                color: ColorUtils.blue,
                fontSize: 20,
              ),
              onChanged: (value) {
                setState(() {
                  _lockTimeout = value;
                });
              },
            ),
            Text(
              AppLocalizations.of(context).getLanguageText('second'),
              style: TextStyle(
                fontSize: 14.0,
                color: ColorUtils.textColor,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  AppLocalizations.of(context).getLanguageText('cancel'),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                child: Text(
                  AppLocalizations.of(context).getLanguageText('confirm'),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: ColorUtils.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () async {
                StoreUtils.setLockScreen(_lockTimeout);
                widget.callback();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}