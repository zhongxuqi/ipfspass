import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'utils/localization.dart';
import 'db/data.dart';
import 'utils/colors.dart';
import 'utils/store.dart';
import 'utils/encrypt.dart' as encrypt;
import 'components/topbar.dart';
import 'components/toast.dart';
import 'utils/ipfs.dart';
import 'utils/content.dart';

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

    final _processingDialogKey = new GlobalKey<_ProcessingDialogState>();
    var dbIns = getDataModel();
    var contentInfos = await dbIns.listContentInfo();
    var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var newContentInfos = <ContentInfo>[];
    for (var contentInfo in contentInfos) {
      var decryptedData = await encrypt.decryptData(modifyMasterPasswordOldCtl.text, contentInfo.encrypted_data);
      var encryptedData = await encrypt.encryptData(modifyMasterPasswordNewCtl.text, decryptedData);
      newContentInfos.add(ContentInfo(contentInfo.id, "", encryptedData, contentInfo.extra, currTime));
    }
    var finishCount = 0;
    var text = "${AppLocalizations.of(context).getLanguageText('processing')} ($finishCount/${newContentInfos.length})";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ProcessingDialog(key: _processingDialogKey, text: text);
        },
    );
    var autoUploadIPFS = await StoreUtils.getAutoUploadIPFS();

    for (var newContentInfo in newContentInfos) {
      await dbIns.updateContentInfo(newContentInfo);
    }
    await StoreUtils.setMasterPassword(modifyMasterPasswordNewCtl.text);

    // 判断是否需要自动同步
    if (autoUploadIPFS) {
      for (var newContentInfo in newContentInfos) {
        var resp = await IPFSUtils.uploadIPFS(newContentInfo.encrypted_data);
        newContentInfo.content_id = resp.data['Name'];
        await dbIns.updateContentInfo(newContentInfo);
        finishCount++;
        text = "${AppLocalizations.of(context).getLanguageText('processing')} ($finishCount/${newContentInfos.length})";
        if (_processingDialogKey.currentState != null) {
          _processingDialogKey.currentState.setText(text);
        }
      }
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if (await StoreUtils.getAutoBackupContent()) backupContent(context);
    }
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

class ProcessingDialog extends StatefulWidget {
  final String text;

  ProcessingDialog({Key key, @required this.text}):super(key: key);

  @override
  State createState() {
    return _ProcessingDialogState();
  }
}

class _ProcessingDialogState extends State<ProcessingDialog> {
  String text;

  @override
  void initState() {
    super.initState();
    text = widget.text;
  }

  void setText(String text) {
    setState(() {
      this.text = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: Colors.transparent,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: Color(0xbb000000),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15.0),
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2.0,
                      ),
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}