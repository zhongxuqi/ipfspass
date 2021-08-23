import 'package:app/utils/content.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/localization.dart';
import 'FormInput.dart';
import '../utils/ipfs.dart';
import 'Toast.dart';
import 'dart:convert';

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

                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
        break;
    }
    return SimpleDialog(
      backgroundColor: ColorUtils.themeColor,
      children: body,
    );
  }
}