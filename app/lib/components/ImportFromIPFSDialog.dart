import 'package:app/db/data.dart';
import 'package:app/utils/content.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/localization.dart';
import 'FormInput.dart';
import '../utils/ipfs.dart';
import 'Toast.dart';
import 'dart:convert';
import '../utils/encrypt.dart' as encrypt;
import 'ContentItem.dart';
import '../common/types.dart';
import '../utils/store.dart';
import '../utils/ipfs.dart';
import 'LoadingDialog.dart';

void showImportFromIPFSDialog(BuildContext context, {@required VoidCallback callback}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ImportFromIPFSDialog(
        callback: callback,
      );
    },
  );
}

class ImportFromIPFSDialog extends StatefulWidget {
  final VoidCallback callback;

  ImportFromIPFSDialog({Key key, @required this.callback}): super(key: key);

  @override
  ImportFromIPFSDialogState createState() => ImportFromIPFSDialogState();
}

class ImportFromIPFSDialogState extends State<ImportFromIPFSDialog> {
  var step = 0;

  final ipfsContentIDCtl = TextEditingController();
  var ipfsContentIDErr = '';
  ContentMessage contentMessage;
  final tempPasswordCtl = TextEditingController();
  var tempPasswordErr = '';
  ContentDetail contentDetail;

  @override
  Widget build(BuildContext context) {
    var body = <Widget>[];
    switch (this.step) {
      case 0:
        body.addAll(<Widget>[
          FormInput(
            keyName: AppLocalizations.of(context).getLanguageText('ipfs_content_id'),
            valueCtl: ipfsContentIDCtl,
            hintText: AppLocalizations.of(context).getLanguageText('ipfs_content_id_hint'),
            onchange: (newText) {
              setState(() {
                ipfsContentIDErr = '';
              });
            },
            errText: ipfsContentIDErr,
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('gonext'),
                        style: TextStyle(
                          color: ColorUtils.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      var hasErr = false;
                      if (ipfsContentIDCtl.text == "") {
                        ipfsContentIDErr = AppLocalizations.of(context).getLanguageText('required');
                        hasErr = true;
                      }
                      if (hasErr) {
                        setState(() {});
                        return;
                      }
                      IPFSUtils.convertIPFSContentID(ipfsContentIDCtl.text).then((value) {
                        if (value.data["errno"] != 0) {
                          showSuccessToast(AppLocalizations.of(context).getLanguageText("download_ipfs_fail"));
                          return;
                        }
                        String cidv1 = value.data["data"]["cid_v1"];
                        IPFSUtils.downloadFromIPFS(cidv1).then((value) {
                          this.contentMessage = ContentMessage.fromJSON(json.encode(value.data));
                          this.step = 1;
                          setState(() {});
                        }).onError((e, s) {
                          showSuccessToast(AppLocalizations.of(context).getLanguageText("download_ipfs_fail"));
                        });
                      }).onError((e, s) {
                        showSuccessToast(AppLocalizations.of(context).getLanguageText("download_ipfs_fail"));
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
        break;
      case 1:
        body.addAll(<Widget>[
          FormInput(
            keyName: AppLocalizations.of(context).getLanguageText('temp_password'),
            valueCtl: tempPasswordCtl,
            hintText: AppLocalizations.of(context).getLanguageText('input_temp_pass_hint'),
            onchange: (newText) {
              setState(() {
                tempPasswordErr = '';
              });
            },
            errText: tempPasswordErr,
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('goback'),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      this.step = 0;
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('gonext'),
                        style: TextStyle(
                          color: ColorUtils.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (this.contentMessage.passwordHash != await encrypt.sha256(tempPasswordCtl.text)) {
                        tempPasswordErr = AppLocalizations.of(context).getLanguageText("temp_pass_wrong");
                        setState(() {});
                        return;
                      }
                      try {
                        var decryptedDataStr = await encrypt.decryptData(tempPasswordCtl.text, this.contentMessage.encryptedData);
                        if (decryptedDataStr == "") {
                          tempPasswordErr = AppLocalizations.of(context).getLanguageText("temp_pass_wrong");
                          setState(() {});
                          return;
                        }
                        var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                        this.contentDetail = await convert2ContentDetail(tempPasswordCtl.text, ContentInfo(null, "",
                            this.contentMessage.encryptedData, ContentExtra(), currTime));
                        this.step = 2;
                        setState(() {});
                      } catch(e) {
                        tempPasswordErr = AppLocalizations.of(context).getLanguageText("temp_pass_wrong");
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
        break;
      case 2:
        List<Widget> formRows = <Widget>[];
        formRows.add(ContentTextItem(
          keyName: AppLocalizations.of(context).getLanguageText('title'),
          value: this.contentDetail.title,
          hintText: AppLocalizations.of(context).getLanguageText('input_title_hint'),
          editable: false,
          onChange: (value) {},
        ));
        switch (this.contentDetail.type) {
          case PasswordType:
            formRows.add(ContentTextItem(
              keyName: AppLocalizations.of(context).getLanguageText('account'),
              value: this.contentDetail.account,
              obscureText: true,
              hintText: AppLocalizations.of(context).getLanguageText('input_account_hint'),
              editable: false,
              onChange: (value) {},
            ));
            formRows.add(ContentPasswordItem(
              keyName: AppLocalizations.of(context).getLanguageText('password'),
              value: this.contentDetail.content,
              obscureText: true,
              hintText: AppLocalizations.of(context).getLanguageText('input_password_hint'),
              editable: false,
              onChange: (value) {},
            ));
            break;
          case TextType:
            formRows.add(ContentTextItem(
              keyName: AppLocalizations.of(context).getLanguageText('text'),
              value: this.contentDetail.content,
              obscureText: true,
              maxLines: null,
              hintText: AppLocalizations.of(context).getLanguageText('input_text_hint'),
              editable: false,
              onChange: (value) {},
            ));
            break;
          case TOTPType:
            formRows.add(ContentTotpItem(
              keyName: AppLocalizations.of(context).getLanguageText('totp_key'),
              value: this.contentDetail.content,
              obscureText: true,
              hintText: AppLocalizations.of(context).getLanguageText('input_totp_hint'),
              editable: false,
              onChange: (value) {},
            ));
            break;
        }
        this.contentDetail.extra.forEach((key, value) {
          formRows.add(ContentTextItem(
            keyName: key,
            value: value,
            obscureText: true,
            hintText: AppLocalizations.of(context).getLanguageText('input_hint'),
            editable: false,
            onChange: (value) {},
            onCloseListener: () {},
          ));
        });
        formRows.add(Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('cancel'),
                      style: TextStyle(
                        color: ColorUtils.textColorGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('save'),
                      style: TextStyle(
                        color: ColorUtils.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () async {
                    var masterPassword = await StoreUtils.getMasterPassword();
                    var contentInfo = await convert2ContentInfo(masterPassword, this.contentDetail);
                    await getDataModel().upsertContentInfo(contentInfo, (id) async {
                      this.contentDetail.id = id;
                      widget.callback();

                      // 判断是否需要上传ipfs
                      if (await StoreUtils.getAutoUploadIPFS()) {
                        showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('upload_ipfs'));
                        var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                        IPFSUtils.uploadIPFS(contentInfo.encrypted_data).then((resp) async {
                          this.contentDetail.content_id = resp.data['Name'];
                          var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                          await getDataModel().upsertContentInfo(contentInfo, (id) {
                            widget.callback();
                          });
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();

                          // 判断是否需要自动同步
                          if (await StoreUtils.getAutoBackupContent()) {
                            backupContent(this.context);
                          }
                        }).catchError((e) {
                          Navigator.of(context).pop();
                        });
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ));
        body.addAll(formRows);
        break;
    }
    return SimpleDialog(
      backgroundColor: ColorUtils.themeColor,
      children: body,
    );
  }
}