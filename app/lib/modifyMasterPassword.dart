import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'utils/localization.dart';
import 'db/data.dart';
import 'utils/colors.dart';
import 'utils/store.dart';
import 'utils/encrypt.dart' as encrypt;
import './components/LoadingDialog.dart';
import 'components/topbar.dart';
import 'components/toast.dart';

class ModifyMasterPasswordPage extends StatefulWidget {
  @override
  ModifyMasterPasswordPageState createState() => new ModifyMasterPasswordPageState();
}

class ModifyMasterPasswordPageState extends State<ModifyMasterPasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var modifyMasterPasswordOldCtl = TextEditingController();
  var modifyMasterPasswordOldErr = "";
  var modifyMasterPasswordNewCtl = TextEditingController();
  var modifyMasterPasswordNewErr = "";
  var modifyMasterPasswordReNewCtl = TextEditingController();
  var modifyMasterPasswordReNewErr = "";

  bool isSubmitting = false;

  modifyMasterPassword() async {
    if (isSubmitting) {
      return;
    }
    isSubmitting = true;
    var hasErr = false;
    if (modifyMasterPasswordOldCtl.text == "") {
      modifyMasterPasswordOldErr = AppLocalizations.of(context).getLanguageText('required');
      hasErr = true;
    }
    if (modifyMasterPasswordNewCtl.text == "") {
      modifyMasterPasswordNewErr = AppLocalizations.of(context).getLanguageText('required');
      hasErr = true;
    }
    if (modifyMasterPasswordReNewCtl.text == "") {
      modifyMasterPasswordReNewErr = AppLocalizations.of(context).getLanguageText('required');
      hasErr = true;
    }
    if (modifyMasterPasswordNewCtl.text != modifyMasterPasswordReNewCtl.text) {
      modifyMasterPasswordReNewErr = AppLocalizations.of(context).getLanguageText('repeat_error');
      hasErr = true;
    }
    if (hasErr) {
      isSubmitting = false;
      setState(() {});
      return;
    }

    // 本地验证主密码
    var masterPassword = modifyMasterPasswordOldCtl.text;
    if (masterPassword != await StoreUtils.getMasterPassword()) {
      showErrorToast(AppLocalizations.of(context).getLanguageText('wrong_masterpassword'));
      isSubmitting = false;
      return;
    }

    var dbIns = getDataModel();
    var contentInfos = await dbIns.listContentInfo();
    var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var newContentInfos = <ContentInfo>[];
    for (var contentInfo in contentInfos) {
      var decryptedData = await encrypt.decryptData(modifyMasterPasswordOldCtl.text, contentInfo.encrypted_data);
      var encryptedData = await encrypt.encryptData(modifyMasterPasswordNewCtl.text, decryptedData);
      newContentInfos.add(ContentInfo(contentInfo.content_id, encryptedData, currTime));
    }
    showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
    for (var newContentInfo in newContentInfos) {
      await dbIns.updateContentInfo(newContentInfo);
    }
    Navigator.of(context).pop();
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
                    title: AppLocalizations.of(context).getLanguageText('modify_master_password'),
                    confirmCallback: () {
                      modifyMasterPassword();
                    },
                    rightButtonText: Text(
                      AppLocalizations.of(context).getLanguageText('confirm'),
                      style: TextStyle(
                        color: ColorUtils.green,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 5.0),
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('old_master_password'),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: ColorUtils.white
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    height: 38,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: modifyMasterPasswordOldCtl,
                            scrollPadding: EdgeInsets.all(0),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                              hintText: AppLocalizations.of(context).getLanguageText('old_master_password_hint'),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                            style: TextStyle(
                              color: ColorUtils.textColor,
                              fontSize: 16.0,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                            onChanged: (newText) {
                              setState(() {
                                modifyMasterPasswordOldErr = '';
                              });
                            },
                            obscureText: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Text(
                            modifyMasterPasswordOldErr,
                            style: TextStyle(
                              color: ColorUtils.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('new_master_password'),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: ColorUtils.textColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    height: 38,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: modifyMasterPasswordNewCtl,
                            scrollPadding: EdgeInsets.all(0),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                              hintText: AppLocalizations.of(context).getLanguageText('new_master_password_hint'),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                            style: TextStyle(
                              color: ColorUtils.textColor,
                              fontSize: 16.0,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                            onChanged: (newText) {
                              setState(() {
                                modifyMasterPasswordNewErr = '';
                              });
                            },
                            obscureText: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Text(
                            modifyMasterPasswordNewErr,
                            style: TextStyle(
                              color: ColorUtils.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('repeat_new_master_password'),
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: ColorUtils.textColor,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    height: 38,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: modifyMasterPasswordReNewCtl,
                            scrollPadding: EdgeInsets.all(0),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                              hintText: AppLocalizations.of(context).getLanguageText('repeat_new_master_password_hint'),
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 16.0,
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                            style: TextStyle(
                              color: ColorUtils.textColor,
                              fontSize: 16.0,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                            onChanged: (newText) {
                              setState(() {
                                modifyMasterPasswordReNewErr = '';
                              });
                            },
                            obscureText: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5.0),
                          child: Text(
                            modifyMasterPasswordReNewErr,
                            style: TextStyle(
                              color: ColorUtils.red,
                            ),
                          ),
                        ),
                      ],
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