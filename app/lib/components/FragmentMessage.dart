import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../common/types.dart';
import '../utils/localization.dart';
import '../utils/content.dart';
import '../utils/colors.dart';
import '../utils/store.dart';
import '../utils/iconfonts.dart';
import 'FormInput.dart';
import 'AddKeyDialog.dart';
import 'Toast.dart';
import '../db/data.dart';
import '../utils/ipfs.dart';
import 'package:flutter/services.dart';
import '../utils/encrypt.dart' as encrypt;

const ModeExist = 'exist';
const ModeNew = 'new';

class FragmentMessage extends StatefulWidget {

  FragmentMessage({Key key}): super(key: key);

  @override
  FragmentMessageState createState() => FragmentMessageState();
}

class FragmentMessageState extends State<FragmentMessage> {

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: ColorUtils.blue,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('send_exist_password'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) {
                      return ModalMessage(mode: ModeExist,);
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.center,
              child: GestureDetector(
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: ColorUtils.green,
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('send_new_password'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                onTap: () {
                  showDialog<Null>(
                    context: context,
                    builder: (BuildContext context) {
                      return ModalMessage(mode: ModeNew,);
                    },
                  );
                },
              ),
            ),
          ),
          Container(height: 100,),
        ],
      ),
    );
  }
}

class ModalMessage extends StatefulWidget {
  final String mode;

  ModalMessage({Key key, @required this.mode}): super(key: key);

  @override
  ModalMessageState createState() {
    return ModalMessageState(mode: mode);
  }
}

class ModalMessageState extends State<ModalMessage> with TickerProviderStateMixin {
  final String mode;
  final keywordCtl = TextEditingController();
  var step = 0;
  var contentTypeValue = 0;
  List<ContentDetail> contentList = <ContentDetail>[];
  ContentDetail selectedContent;

  final tempPasswordCtl = TextEditingController();
  String tempPasswordErr = '';
  final hintWordCtl = TextEditingController();
  String contentID = '';

  List<ContentType> contentTypes;

  // password
  final passwordTitleCtl = TextEditingController();
  var passwordTitleErr = '';
  final passwordAccountCtl = TextEditingController();
  final passwordContentCtl = TextEditingController();
  var passwordContentErr = '';

  // text
  final textTitleCtl = TextEditingController();
  var textTitleErr = '';
  final textContentCtl = TextEditingController();
  var textContentErr = '';

  // totp
  final totpTitleCtl = TextEditingController();
  var totpTitleErr = '';
  final totpContentCtl = TextEditingController();
  var totpContentErr = '';

  // blockchain
  final digitalWalletTitleCtl = TextEditingController();
  var digitalWalletTitleErr = '';
  final digitalWalletCoinNameCtl = TextEditingController();
  final digitalWalletAddressCtl = TextEditingController();
  final digitalWalletPubKeyCtl = TextEditingController();
  final digitalWalletPriKeyCtl = TextEditingController();
  final digitalWalletKeyStoreCtl = TextEditingController();
  final digitalWalletHintWordCtl = TextEditingController();

  // extra data
  Map<String, dynamic> extra = Map<String, dynamic>();
  Map<String, TextEditingController> extraInputMap = Map<String, TextEditingController>();

  ModalMessageState({@required this.mode}): super();

  @override
  void initState() {
    super.initState();
    step = 0;
    initContentList();
  }

  initContentList() async {
    var masterPassword = await StoreUtils.getMasterPassword();
    if (masterPassword == null) return;
    try {
      contentList = await listContentDetail(masterPassword, 0);
    } on Exception catch (e) {
      print("${e.toString()}");
      initContentList();
      return;
    }
    setState(() {});
  }

  void selectContent(ContentDetail content) {
    this.selectedContent = content;
    this.step = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (contentTypes == null) {
      contentTypes = <ContentType>[
        ContentType(
          value: 0,
          desc: AppLocalizations.of(context).getLanguageText('password'),
        ),
        ContentType(
          value: 1,
          desc: AppLocalizations.of(context).getLanguageText('text'),
        ),
        ContentType(
          value: 2,
          desc: AppLocalizations.of(context).getLanguageText('totp'),
        ),
      ];
    }

    List<Widget> body;
    if (this.step == 0) {
      if (mode == ModeExist) {
        body = <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            decoration: BoxDecoration(
              color: ColorUtils.themeLightColor,
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CupertinoTextField(
                    controller: keywordCtl,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: AppLocalizations.of(context).getLanguageText('keyword_hint'),
                    placeholderStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: (_) {
                      setState(() {

                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ];
        List<ContentDetail> filterContentList;
        if (this.keywordCtl.text == '') {
          filterContentList = contentList;
        } else {
          filterContentList = contentList.where((contentDetail) {
            if (contentDetail.title.toLowerCase().contains(this.keywordCtl.text.toLowerCase())) {
              return true;
            }
            return false;
          }).toList();
        }
        body.addAll(filterContentList.map((item) {
          return ContentItem(
            contentDetail: item,
            onClickListener: () {
              selectContent(item);
            },
            onLongPressListener: () {

            },
          );
        }));
      } else {
        ContentType contentType;
        for (int i=0;i<contentTypes.length;i++) {
          if (contentTypes[i].value == contentTypeValue) {
            contentType = contentTypes[i];
          }
        }
        body = <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10, right: 10.0, bottom: 5.0),
            child: Text(
              AppLocalizations.of(context).getLanguageText('content_type'),
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          PopupMenuButton<ContentType>(
            initialValue: contentType,
            child: Container(
              height: 33.0,
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              padding: EdgeInsets.symmetric(vertical: 0.0,horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      child:Text(
                        contentType.desc,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    IconFonts.arrow_down,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            onSelected: (ContentType value) {
              setState(() {
                this.contentTypeValue = value.value;
              });
            },
            itemBuilder: (BuildContext context) => contentTypes.map((item) {
              return PopupMenuItem<ContentType>(
                value: item,
                child: Container(
                  child: Text(
                    item.desc,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ];
        switch (contentTypeValue) {
          case 0:
            body.addAll(<Widget>[
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('title'),
                valueCtl: passwordTitleCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_title_hint'),
                onchange: (newText) {
                  setState(() {
                    passwordTitleErr = '';
                  });
                },
                errText: passwordTitleErr,
              ),
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('account_optional'),
                valueCtl: passwordAccountCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_account_hint'),
                onchange: (newText) {},
                errText: '',
              ),
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('password'),
                valueCtl: passwordContentCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_password_hint'),
                onchange: (newText) {
                  setState(() {
                    passwordContentErr = '';
                  });
                },
                errText: passwordContentErr,
              ),
            ]);
            break;
          case 1:
            body.addAll(<Widget>[
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('title'),
                valueCtl: textTitleCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_title_hint'),
                onchange: (newText) {
                  setState(() {
                    textTitleErr = '';
                  });
                },
                errText: textTitleErr,
              ),
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('text'),
                valueCtl: textContentCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_text_hint'),
                onchange: (newText) {
                  setState(() {
                    textContentErr = '';
                  });
                },
                errText: textContentErr,
                isMultiLine: true,
              ),
            ]);
            break;
          case 2:
            body.addAll(<Widget>[
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('title'),
                valueCtl: totpTitleCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_title_hint'),
                onchange: (newText) {
                  setState(() {
                    totpTitleErr = '';
                  });
                },
                errText: totpTitleErr,
              ),
              FormInput(
                keyName: AppLocalizations.of(context).getLanguageText('totp'),
                valueCtl: totpTitleCtl,
                hintText: AppLocalizations.of(context).getLanguageText('input_totp_hint'),
                onchange: (newText) {
                  setState(() {
                    totpContentErr = '';
                  });
                },
                errText: totpContentErr,
              ),
            ]);
            break;
        }

        // add extra
        body.add(Container(
          height: 1.0,
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
        ));
        for (var key in extra.keys) {
          TextEditingController valueCtl;
          if (extraInputMap.containsKey(key)) {
            valueCtl = extraInputMap[key];
          } else {
            valueCtl = TextEditingController();
            extraInputMap[key] = valueCtl;
          }
          body.add(Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: FormInput(
                    keyName: key,
                    valueCtl: valueCtl,
                    hintText: '',
                    onchange: (newText) {},
                    errText: '',
                  ),
                ),
                GestureDetector(
                  child: Container(
                    child: Icon(
                      IconFonts.close,
                      color: Colors.red,
                      size: 20.0,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      extra.remove(key);
                      extraInputMap.remove(key);
                    });
                  },
                ),
              ],
            ),
          ));
        }
        body.add(Container(
          padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
          child: InkWell(
            splashColor: Colors.white,
            highlightColor: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              padding: EdgeInsets.all(5.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                AppLocalizations.of(context).getLanguageText('add_key'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
            onTap: () {
              showAddKeyDialog(context,
                callback: (keyName) {
                  if (extra.containsKey(keyName)) {
                    showErrorToast(AppLocalizations.of(context).getLanguageText('key_exists'));
                  } else {
                    Navigator.of(context).pop();
                    setState(() {
                      extra[keyName] = '';
                    });
                  }
                },
                keyName: AppLocalizations.of(context).getLanguageText('key_name'),
                keyNameHint: AppLocalizations.of(context).getLanguageText('key_name_hint'),
                initValue: '',
              );
            },
          ),
        ));

        body.addAll(<Widget>[
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
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                      for (var key in extra.keys) {
                        extra[key] = extraInputMap[key].text;
                      }
                      switch (contentTypeValue) {
                        case 0:
                          var hasErr = false;
                          if (passwordTitleCtl.text == "") {
                            passwordTitleErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (passwordContentCtl.text == "") {
                            passwordContentErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (hasErr) {
                            setState(() {});
                            return;
                          }
                          selectedContent = ContentDetail(null, "", currTime, ContentExtra(), passwordTitleCtl.text, passwordContentCtl.text, PasswordType, passwordAccountCtl.text, extra, <String>[]);
                          this.step = 1;
                          setState(() {});
                          break;
                        case 1:
                          var hasErr = false;
                          if (textTitleCtl.text == "") {
                            textTitleErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (textContentCtl.text == "") {
                            textContentErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (hasErr) {
                            setState(() {});
                            return;
                          }
                          selectedContent = ContentDetail(null, "", currTime, ContentExtra(), textTitleCtl.text, textContentCtl.text, TextType, '', extra, <String>[]);
                          this.step = 1;
                          setState(() {});
                          break;
                        case 2:
                          var hasErr = false;
                          if (totpTitleCtl.text == "") {
                            totpTitleErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (totpContentCtl.text == "") {
                            totpContentErr = AppLocalizations.of(context).getLanguageText('required');
                            hasErr = true;
                          }
                          if (hasErr) {
                            setState(() {});
                            return;
                          }
                          selectedContent = ContentDetail(null, "", currTime, ContentExtra(), totpTitleCtl.text, totpContentCtl.text, TOTPType, '', extra, <String>[]);
                          this.step = 1;
                          setState(() {});
                          break;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ]);
      }
    } else if (this.step == 1) {
      body = <Widget>[
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
        FormInput(
          keyName: AppLocalizations.of(context).getLanguageText('message_hint_word'),
          valueCtl: hintWordCtl,
          hintText: AppLocalizations.of(context).getLanguageText('input_message_hint_word_hint'),
          onchange: (newText) {},
          errText: '',
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
                  onTap: () {
                    var hasErr = false;
                    if (tempPasswordCtl.text == '') {
                      tempPasswordErr = AppLocalizations.of(context).getLanguageText('required');
                      hasErr = true;
                    }
                    if (hasErr) {
                      setState(() {});
                      return;
                    }
                    this.step = 2;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (this.step == 2) {
      String contentTypeDesc;
      switch (contentTypeValue) {
        case 0:
          contentTypeDesc = AppLocalizations.of(context).getLanguageText('password');
          break;
        case 1:
          contentTypeDesc = AppLocalizations.of(context).getLanguageText('text');
          break;
        case 2:
          contentTypeDesc = AppLocalizations.of(context).getLanguageText('totp');
          break;
      }
      body = <Widget>[
        Container(
          margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('content_type'),
                    style: TextStyle(
                      color: ColorUtils.textColorGrey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    contentTypeDesc,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('content_title'),
                    style: TextStyle(
                      color: ColorUtils.textColorGrey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    selectedContent.title,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('temp_password'),
                    style: TextStyle(
                      color: ColorUtils.textColorGrey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    tempPasswordCtl.text,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0,bottom: 5.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 3.0, horizontal: 0.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).getLanguageText('message_hint_word'),
                    style: TextStyle(
                      color: ColorUtils.textColorGrey,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    hintWordCtl.text,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                    this.step = 1;
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
                      AppLocalizations.of(context).getLanguageText('pack'),
                      style: TextStyle(
                        color: ColorUtils.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () async {
                    if (this.step >= 3) return;
                    this.step = 3;
                    setState(() {});
                    var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                    var contentInfo = await convert2ContentInfo(tempPasswordCtl.text,
                        ContentDetail(null, '', currTime, ContentExtra(), selectedContent.title, selectedContent.content, selectedContent.type, selectedContent.account, selectedContent.extra, <String>[]));
                    if (contentInfo == null) {
                      this.step = 2;
                      setState(() {});
                      return;
                    }
                    var contentMessage = ContentMessage(hint: hintWordCtl.text, passwordHash: await encrypt.sha256(tempPasswordCtl.text), encryptedData: contentInfo.encrypted_data);
                    IPFSUtils.uploadIPFS(contentMessage.toJSON()).then((resp) async {
                      this.contentID = resp.data['Name'];
                      this.step = 4;
                      setState(() {});
                    }).catchError((e) {
                      showErrorToast(AppLocalizations.of(context).getLanguageText('upload_ipfs_fail'));
                      this.step = 2;
                      setState(() {});
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ];
    } else if (this.step == 3) {
      body = <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 15.0),
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorUtils.white),
            strokeWidth: 2.0,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).getLanguageText('packing'),
              style: TextStyle(
                fontSize: 15.0,
                color: ColorUtils.white,
              ),
            ),
          ],
        ),
      ];
    } else if (this.step == 4) {
      body = <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
          child: Text(
            AppLocalizations.of(context).getLanguageText('pack_result'),
            style: TextStyle(
              color: ColorUtils.textColor,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex:1,
              child:GestureDetector(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('images/link.png', height: 50.0, width: 50.0,),
                    Padding(
                      child:Text(
                        AppLocalizations.of(context).getLanguageText('copy_ipfs'),
                        style: TextStyle(
                          fontSize:12,
                          color: ColorUtils.textColor
                        ),
                      ),
                      padding:EdgeInsets.all(8),
                    ),
                  ],
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: this.contentID));
                  showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                }
              ),
            ),
          ],
        ),
      ];
    }
    return SimpleDialog(
      backgroundColor: ColorUtils.themeColor,
      children: body,
    );
  }
}

class ContentType {
  final int value;
  final String desc;

  ContentType({@required this.value, @required this.desc});
}

class ContentItem extends StatelessWidget {
  final ContentDetail contentDetail;
  final VoidCallback onClickListener;
  final VoidCallback onLongPressListener;

  ContentItem({Key key, @required this.contentDetail,
    @required this.onClickListener, @required this.onLongPressListener}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemIcon = "images/ic_tag.png";
    var itemIconColor = ColorUtils.getTagColor();
    var itemIconBgColor = ColorUtils.getTagBgColor();
    switch (contentDetail.type) {
      case PasswordType:
        itemIcon = "images/ic_key.png";
        itemIconColor = ColorUtils.getPasswordColor();
        itemIconBgColor = ColorUtils.getPasswordBgColor();
        break;
      case TextType:
        itemIcon = "images/ic_file-text.png";
        itemIconColor = ColorUtils.getTextColor();
        itemIconBgColor = ColorUtils.getTextBgColor();
        break;
      case TOTPType:
        itemIcon = "images/ic_stopwatch.png";
        itemIconColor = ColorUtils.getTotpColor();
        itemIconBgColor = ColorUtils.getTotpBgColor();
        break;
    }
    return InkWell(
      onTap: onClickListener,
      onLongPress: onLongPressListener,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: itemIconBgColor,
                  border: Border.all(color: itemIconColor),
                  borderRadius: BorderRadius.all(Radius.circular(999.0))
              ),
              child: Image.asset(itemIcon, width: 16.0, height: 16.0),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 5.0, top: 13.0, bottom: 13.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ColorUtils.divider)),
                ),
                child: Text(
                  contentDetail.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: ColorUtils.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}