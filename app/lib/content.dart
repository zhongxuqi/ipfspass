import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'components/ContentTopbar.dart';
import 'utils/iconfonts.dart';
import 'utils/localization.dart';
import 'utils/content.dart';
import 'db/data.dart';
import 'common/types.dart';
import 'components/toast.dart';
import 'dart:convert';
import 'utils/store.dart';
import 'components/AddKeyDialog.dart';
import 'dart:math';
import 'utils/colors.dart';
import 'dart:async';
import "package:otp/otp.dart";
import 'package:permission_handler/permission_handler.dart';
import 'QrScanner.dart';

class ContentPage extends StatefulWidget {
  final VoidCallback refreshCallback;
  final String contentID;
  final int contentType;
  final String tagName;

  ContentPage({Key key, this.contentID, @required this.contentType, @required this.refreshCallback, @required this.tagName}):super(key: key);

  @override
  State<StatefulWidget> createState() => ContentPageState(
    contentID: this.contentID,
    refreshCallback: this.refreshCallback,
    contentType: this.contentType,
    tagName: this.tagName,
  );
}

class ContentPageState extends State<ContentPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final VoidCallback refreshCallback;
  final int contentType;
  final String tagName;
  String contentID;

  ContentDetail contentDetail;

  bool isSubmitting = false;
  bool editable = false;

  // common
  final GlobalKey<ContentTextItemState> _titleScaffoldKey = GlobalKey<ContentTextItemState>();
  String title = '';
  final Map<String, GlobalKey<ContentTextItemState>> _extraScaffoldKeyMap = Map<String, GlobalKey<ContentTextItemState>>();
  Map<String, dynamic> extra = Map<String, dynamic>();

  // password
  final GlobalKey<ContentPasswordItemState> _passwordScaffoldKey = GlobalKey<ContentPasswordItemState>();
  String password = '';
  final GlobalKey<ContentTextItemState> _accountScaffoldKey = GlobalKey<ContentTextItemState>();
  String account = '';

  // text
  final GlobalKey<ContentTextItemState> _textScaffoldKey = GlobalKey<ContentTextItemState>();
  String text = '';

  // totp
  final GlobalKey<ContentTotpItemState> _totpScaffoldKey = GlobalKey<ContentTotpItemState>();
  String totp = '';

  // blockchain
  final GlobalKey<ContentTextItemState> _coinNameScaffoldKey = GlobalKey<ContentTextItemState>();
  String coinName = '';
  final GlobalKey<ContentTextItemState> _addressScaffoldKey = GlobalKey<ContentTextItemState>();
  String address = '';
  final GlobalKey<ContentTextItemState> _pubkeyScaffoldKey = GlobalKey<ContentTextItemState>();
  String pubkey = '';
  final GlobalKey<ContentTextItemState> _prikeyScaffoldKey = GlobalKey<ContentTextItemState>();
  String prikey = '';
  final GlobalKey<ContentTextItemState> _keyStoreScaffoldKey = GlobalKey<ContentTextItemState>();
  String keyStore = '';
  final GlobalKey<ContentTextItemState> _hintWordScaffoldKey = GlobalKey<ContentTextItemState>();
  String hintWord = '';

  ContentPageState({this.contentID, this.contentType, @required this.refreshCallback, @required this.tagName});

  @override
  initState() {
    super.initState();
    editable = contentID == null;
    getContentDetail();
  }

  getContentDetail() async {
    if (contentID != null) {
      var instance = getDataModel();
      var contentInfo = await instance.getContentInfo(contentID);
      var masterPassword = await StoreUtils.getMasterPassword();
      contentDetail = await convert2ContentDetail(masterPassword, contentInfo);
      renderContentDetail();
    }
  }

  renderContentDetail() {
    title = contentDetail.title;
    switch (contentDetail.type) {
      case PasswordType:
        account = contentDetail.account==null?'':contentDetail.account;
        password = contentDetail.content;
        break;
      case TextType:
        text = contentDetail.content;
        break;
      case TOTPType:
        totp = contentDetail.content;
        break;
    }
    extra.clear();
    extra.addAll(contentDetail.extra);
    for (var key in extra.keys) {
      if (!_extraScaffoldKeyMap.containsKey(key)) {
        _extraScaffoldKeyMap[key] = GlobalKey<ContentTextItemState>();
      } else if (_extraScaffoldKeyMap[key].currentState != null) {
        _extraScaffoldKeyMap[key].currentState.setValue(extra[key]);
      }
    }
    if (_titleScaffoldKey.currentState != null) {
      _titleScaffoldKey.currentState.setValue(title);
    }
    switch (contentDetail.type) {
      case PasswordType:
        if (_accountScaffoldKey.currentState != null) {
          _accountScaffoldKey.currentState.setValue(account);
        }
        if (_passwordScaffoldKey.currentState != null) {
          _passwordScaffoldKey.currentState.setValue(password);
        }
        break;
      case TextType:
        if (_textScaffoldKey.currentState != null) {
          _textScaffoldKey.currentState.setValue(text);
        }
        break;
      case TOTPType:
        if (_totpScaffoldKey.currentState != null) {
          _totpScaffoldKey.currentState.setValue(totp);
        }
        break;
    }
    setState(() {});
  }

  setEditable(bool editable) {
    this.editable = editable;
    for (var key in _extraScaffoldKeyMap.keys) {
      _extraScaffoldKeyMap[key].currentState.setEditable(editable);
    }
    if (_titleScaffoldKey.currentState != null) {
      _titleScaffoldKey.currentState.setEditable(editable);
    }
    if (_accountScaffoldKey.currentState != null) {
      _accountScaffoldKey.currentState.setEditable(editable);
    }
    if (_passwordScaffoldKey.currentState != null) {
      _passwordScaffoldKey.currentState.setEditable(editable);
    }
    if (_textScaffoldKey.currentState != null) {
      _textScaffoldKey.currentState.setEditable(editable);
    }
    if (_totpScaffoldKey.currentState != null) {
      _totpScaffoldKey.currentState.setEditable(editable);
    }
    if (_coinNameScaffoldKey.currentState != null) {
      _coinNameScaffoldKey.currentState.setEditable(editable);
    }
    if (_addressScaffoldKey.currentState != null) {
      _addressScaffoldKey.currentState.setEditable(editable);
    }
    if (_pubkeyScaffoldKey.currentState != null) {
      _pubkeyScaffoldKey.currentState.setEditable(editable);
    }
    if (_prikeyScaffoldKey.currentState != null) {
      _prikeyScaffoldKey.currentState.setEditable(editable);
    }
    if (_keyStoreScaffoldKey.currentState != null) {
      _keyStoreScaffoldKey.currentState.setEditable(editable);
    }
    if (_hintWordScaffoldKey.currentState != null) {
      _hintWordScaffoldKey.currentState.setEditable(editable);
    }
  }

//  void onDeleteClick() {
//    showAlertDialog(context, AppLocalizations.of(context).getLanguageText('affirm_delete_content'),
//      callback: () {
//        mypass.deleteContent(contentDetail).then((resp) async {
//          Map<String, dynamic> registerResp = json.decode(resp.body);
//          if (registerResp['errno'] != 0) {
//            var errMsg = AppLocalizations.of(context).getLanguageText('net_error');
//            switch (registerResp['errno']) {
//              case 4000011:
//                errMsg = AppLocalizations.of(context).getLanguageText('dup_account');
//                break;
//            }
//            showErrorToast(errMsg);
//            return;
//          }
//          var instance = getDataModel();
//          await instance.deleteContentInfo(contentDetail.content_id);
//          refreshCallback();
//          Navigator.of(context).pop();
//        });
//      },
//    );
//  }

  void submit() async {
    if (isSubmitting) {
      return;
    }
    isSubmitting = true;
    var hasErr = false;
    if (title == "") {
      _titleScaffoldKey.currentState.setTextError(AppLocalizations.of(context).getLanguageText('required'));
      hasErr = true;
    }
    switch (contentType) {
      case PasswordType:
        if (password == "") {
          _passwordScaffoldKey.currentState.setTextError(AppLocalizations.of(context).getLanguageText('required'));
          hasErr = true;
        }
        break;
      case TextType:
        if (text == "") {
          _textScaffoldKey.currentState.setTextError(AppLocalizations.of(context).getLanguageText('required'));
          hasErr = true;
        }
        break;
      case TOTPType:
        if (totp == "") {
          _totpScaffoldKey.currentState.setTextError(AppLocalizations.of(context).getLanguageText('required'));
          hasErr = true;
        }
        break;
    }
    if (hasErr) {
      isSubmitting = false;
      setState(() {});
      return;
    }
    String content = "";
    switch (contentType) {
      case PasswordType:
        content = password;
        break;
      case TextType:
        content = text;
        break;
      case TOTPType:
        content = totp;
        break;
    }
    var newExtra = Map<String, dynamic>();
    newExtra.addAll(this.extra);
    var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var tags = <String>[];
    if (this.contentDetail != null && this.contentDetail.tags != null) {
      for (var tagItem in this.contentDetail.tags) {
        if (tagItem != null && tagItem != '' && !tags.contains(tagItem)) {
          tags.add(tagItem);
        }
      }
    }
    if (tagName != null && tagName != '' && !tags.contains(tagName)) {
      tags.add(tagName);
    }
    var contentDetail = ContentDetail(contentID, currTime, title, content, "blue", contentType, this.account, newExtra, tags);
    if (contentID == null) {
      contentDetail.content_id = Uuid().v4();
      var masterPassword = await StoreUtils.getMasterPassword();
      var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
      getDataModel().insertContentInfo(contentInfo);
      this.refreshCallback();
      contentID = contentDetail.content_id;
      this.contentDetail = contentDetail;
      setEditable(false);
      renderContentDetail();
    } else {
      var masterPassword = await StoreUtils.getMasterPassword();
      var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
      getDataModel().updateContentInfo(contentInfo);
      this.refreshCallback();
      this.contentDetail = contentDetail;
      setEditable(false);
      renderContentDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formRows = <Widget>[];
    formRows.add(ContentTextItem(
      key: _titleScaffoldKey,
      keyName: AppLocalizations.of(context).getLanguageText('title'),
      value: title,
      hintText: AppLocalizations.of(context).getLanguageText('input_title_hint'),
      editable: editable,
      onChange: (value) {
        title = value;
        _titleScaffoldKey.currentState.setTextError('');
      },
    ));
    switch (contentType) {
      case PasswordType:
        formRows.add(ContentTextItem(
          key: _accountScaffoldKey,
          keyName: AppLocalizations.of(context).getLanguageText('account'),
          value: account,
          obscureText: true,
          hintText: AppLocalizations.of(context).getLanguageText('input_account_hint'),
          editable: editable,
          onChange: (value) {
            account = value;
          },
        ));
        formRows.add(ContentPasswordItem(
          key: _passwordScaffoldKey,
          keyName: AppLocalizations.of(context).getLanguageText('password'),
          value: password,
          obscureText: true,
          hintText: AppLocalizations.of(context).getLanguageText('input_password_hint'),
          editable: editable,
          onChange: (value) {
            password = value;
            _passwordScaffoldKey.currentState.setTextError('');
          },
        ));
        break;
      case TextType:
        formRows.add(ContentTextItem(
          key: _textScaffoldKey,
          keyName: AppLocalizations.of(context).getLanguageText('text'),
          value: text,
          maxLines: null,
          hintText: AppLocalizations.of(context).getLanguageText('input_text_hint'),
          editable: editable,
          onChange: (value) {
            text = value;
            _textScaffoldKey.currentState.setTextError('');
          },
        ));
        break;
      case TOTPType:
        formRows.add(ContentTotpItem(
          key: _totpScaffoldKey,
          keyName: AppLocalizations.of(context).getLanguageText('totp_key'),
          value: totp,
          obscureText: true,
          hintText: AppLocalizations.of(context).getLanguageText('input_totp_hint'),
          editable: editable,
          onChange: (value) {
            totp = value;
            _totpScaffoldKey.currentState.setTextError('');
          },
        ));
        break;
    }
    extra.forEach((key, value) {
      formRows.add(ContentTextItem(
        key: _extraScaffoldKeyMap[key],
        keyName: key,
        value: extra[key],
        hintText: AppLocalizations.of(context).getLanguageText('input_hint'),
        editable: editable,
        onChange: (value) {
          extra[key] = value;
        },
        onCloseListener: () {
          extra.remove(key);
          _extraScaffoldKeyMap.remove(key);
          setState(() {

          });
        },
      ));
    });
    if (this.editable) {
      formRows.add(Container(
        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: MediaQuery.of(context).size.width * 0.07),
        padding: EdgeInsets.symmetric(vertical: 7.0),
        child: InkWell(
          splashColor: Colors.white,
          highlightColor: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff212121),
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
                    _extraScaffoldKeyMap[keyName] = GlobalKey<ContentTextItemState>();
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
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          children: <Widget>[
            ContentTopBar(
              contentType: contentType,
              actions: this.editable?<ContentTopBarAction>[
                this.contentID==null?null:ContentTopBarAction(
                  text: Text(
                    AppLocalizations.of(context).getLanguageText('cancel'),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15.0,
                    ),
                  ),
                  onClickListener: () {
                    setEditable(false);
                    setState(() {
                      this.editable = false;
                    });
                    renderContentDetail();
                  },
                ),
                ContentTopBarAction(
                  text: Text(
                    AppLocalizations.of(context).getLanguageText('submit'),
                    style: TextStyle(
                      color: const Color(0xff764ba2),
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onClickListener: submit,
                ),
              ]:<ContentTopBarAction>[
                ContentTopBarAction(
                  text: Text(
                    AppLocalizations.of(context).getLanguageText('edit'),
                    style: TextStyle(
                      color: Colors.yellow[800],
                      fontSize: 15.0,
                    ),
                  ),
                  onClickListener: () {
                    setEditable(true);
                    setState(() {
                      this.editable = true;
                    });
                  },
                ),
//                ContentTopBarAction(
//                  text: Text(
//                    AppLocalizations.of(context).getLanguageText('delete'),
//                    style: TextStyle(
//                      color: Colors.red[800],
//                      fontSize: 15.0,
//                    ),
//                  ),
//                  onClickListener: onDeleteClick,
//                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 50.0),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: new SliverChildListDelegate(
                      formRows,
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

class ContentTextItem extends StatefulWidget {
  final String keyName;
  String value;
  bool editable;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String> onChange;
  final VoidCallback onCloseListener;
  final String hintText;

  ContentTextItem({Key key, @required this.keyName, @required this.value, @required this.hintText, this.editable = false,
    this.obscureText = false, this.maxLines = 1, @required this.onChange, this.onCloseListener = null}): super(key: key);

  @override
  State<StatefulWidget> createState() => ContentTextItemState(
    keyName: this.keyName,
    value: this.value,
    editable: this.editable,
    hintText: this.hintText,
  );
}

class ContentTextItemState extends State<ContentTextItem> {
  final String keyName;
  String value;
  bool editable;
  final textCtl = TextEditingController();
  bool isShow = false;
  final String hintText;

  ContentTextItemState({@required this.keyName, @required this.value, @required this.hintText, this.editable = false});

  @override
  void initState() {
    super.initState();
    textCtl.text = value;
  }

  void setValue(String v) {
    setState(() {
      value = v;
      textCtl.text = value;
    });
  }

  void setEditable(bool v) {
    setState(() {
      editable = v;
      _textError = "";
    });
  }

  String _textError = "";
  setTextError(String value) {
    setState(() {
      _textError = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: MediaQuery.of(context).size.width * 0.07),
      padding: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]))
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    keyName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              widget.obscureText?GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset(isShow?'images/ic_eye.png':'images/ic_eye-slash.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  setState(() {
                    this.isShow = !this.isShow;
                  });
                },
              ):Container(),
              GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: editable&&widget.onCloseListener!=null?10.0:0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset('images/ic_copy.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                },
              ),
              editable&&widget.onCloseListener!=null?GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset('images/ic_close.png', width: 14.0, height: 14.0),
                ),
                onTap: widget.onCloseListener,
              ):Container(),
            ],
          ),
          editable?Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xfff2f4f8),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CupertinoTextField(
                    controller: textCtl,
                    obscureText: widget.obscureText?!isShow:false,
                    maxLines: (widget.obscureText?isShow:true)?widget.maxLines:1,
                    minLines: widget.maxLines==null&&(widget.obscureText?isShow:true)?2:1,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: widget.onChange,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _textError,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ):Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 20.0,
                  ),
                  margin: EdgeInsets.only(bottom: 0.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: !widget.obscureText||isShow?Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: Colors.grey[700],
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContentPasswordItem extends StatefulWidget {
  final String keyName;
  String value;
  bool editable;
  final bool obscureText;
  final int maxLines;
  final ValueChanged<String> onChange;
  final String hintText;

  ContentPasswordItem({Key key, @required this.keyName, @required this.value, @required this.hintText, this.editable = false,
    this.obscureText = false, this.maxLines = 1, @required this.onChange}): super(key: key);

  @override
  State<StatefulWidget> createState() => ContentPasswordItemState(
    keyName: this.keyName,
    value: this.value,
    editable: editable,
    hintText: hintText,
  );
}

class ContentPasswordItemState extends State<ContentPasswordItem> {
  final String keyName;
  String value;
  bool editable;
  final textCtl = TextEditingController();
  bool isShow = false;
  final String hintText;

  double passwordLen = 12.0;
  bool lowcase = true;
  bool highcase = true;
  bool number = true;
  bool symbol1 = false;
  bool symbol2 = false;
  bool symbol3 = false;
  bool symbol4 = false;

  ContentPasswordItemState({@required this.keyName, @required this.value, @required this.hintText, this.editable = false});

  @override
  void initState() {
    super.initState();
    textCtl.text = value;
  }

  void setValue(String v) {
    setState(() {
      value = v;
      textCtl.text = value;
    });
  }

  void setEditable(bool v) {
    setState(() {
      editable = v;
      _textError = "";
    });
  }

  String _textError = "";
  setTextError(String value) {
    setState(() {
      _textError = value;
    });
  }

  generatePassword() {
    String passwordElement = '';
    if (lowcase) {
      passwordElement += 'abcdefghijklmnopqrstuvwxyz';
    }
    if (highcase) {
      passwordElement += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    }
    if (number) {
      passwordElement += '01234689';
    }
    if (symbol1) {
      passwordElement += '!!!!';
    }
    if (symbol2) {
      passwordElement += '@@@@';
    }
    if (symbol3) {
      passwordElement += '####';
    }
    if (symbol4) {
      passwordElement += '\$\$\$\$';
    }
    var rand = Random();
    var passwordContent = '';
    for (var i=0;i<passwordLen;i++) {
      passwordContent += passwordElement[rand.nextInt(passwordElement.length)];
    }
    setState(() {
      textCtl.text = passwordContent;
      if (widget.onChange != null) {
        widget.onChange(textCtl.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> generatorWidget = <Widget>[];
    if (editable) {
      generatorWidget.addAll(<Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(15.0, 12.0, 15.0, 12.0),
          child: InkWell(
            splashColor: Colors.white,
            highlightColor: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              padding: EdgeInsets.all(10.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorUtils.getPasswordColor(),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                AppLocalizations.of(context).getLanguageText('generate'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
              ),
            ),
            onTap: () {
              generatePassword();
            },
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                child: Slider(
                  value: passwordLen,
                  max: 24,
                  min: 6,
                  activeColor: ColorUtils.getPasswordColor(),
                  onChanged: (double val) {
                    setState(() {
                      passwordLen = val;
                    });
                  },
                ),
              ),
            ),
            Container(
              child: Text(
                passwordLen.toInt().toString(),
                style: TextStyle(
                  color: ColorUtils.getPasswordColor(),
                  fontSize: 15.0,
                ),
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(bottom: 15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0,),
                        child: Icon(
                          highcase?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          highcase = !highcase;
                        });
                      },
                    ),
                    Text(
                      'A-Z',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          lowcase?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          lowcase = !lowcase;
                        });
                      },
                    ),
                    Text(
                      'a-z',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          number?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          number = !number;
                        });
                      },
                    ),
                    Text(
                      '0-9',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          symbol1?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          symbol1 = !symbol1;
                        });
                      },
                    ),
                    Text(
                      '!',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          symbol2?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          symbol2 = !symbol2;
                        });
                      },
                    ),
                    Text(
                      '@',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          symbol3?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          symbol3 = !symbol3;
                        });
                      },
                    ),
                    Text(
                      '#',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        margin: EdgeInsets.only(right: 10.0),
                        child: Icon(
                          symbol4?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
                          color: ColorUtils.getPasswordColor(),
                          size: 20.0,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          symbol4 = !symbol4;
                        });
                      },
                    ),
                    Text(
                      '\$',
                      style: TextStyle(
                        color: ColorUtils.getPasswordColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]);
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: MediaQuery.of(context).size.width * 0.07),
      padding: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100])),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    keyName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              widget.obscureText?GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset(isShow?'images/ic_eye.png':'images/ic_eye-slash.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  setState(() {
                    this.isShow = !this.isShow;
                  });
                },
              ):Container(),
              GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: 0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset('images/ic_copy.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                },
              ),
            ],
          ),
          editable?Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xfff2f4f8),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CupertinoTextField(
                    controller: textCtl,
                    obscureText: widget.obscureText?!isShow:false,
                    maxLines: widget.maxLines,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: widget.onChange,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _textError,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ],
            ),
          ):Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 20.0,
                  ),
                  margin: EdgeInsets.only(bottom: 0.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: !widget.obscureText||isShow?Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: Colors.grey[700],
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
        ]..addAll(generatorWidget),
      ),
    );
  }
}

class ContentTotpItem extends StatefulWidget {
  final String keyName;
  String value;
  bool editable;
  final bool obscureText;
  final ValueChanged<String> onChange;
  final VoidCallback onCloseListener;
  final String hintText;

  ContentTotpItem({Key key, @required this.keyName, @required this.value, @required this.hintText, this.editable = false,
    this.obscureText = false, @required this.onChange, this.onCloseListener}): super(key: key);

  @override
  State<StatefulWidget> createState() => ContentTotpItemState(
    keyName: this.keyName,
    value: this.value,
    editable: this.editable,
    hintText: this.hintText,
  );
}

class ContentTotpItemState extends State<ContentTotpItem> {
  final String keyName;
  String value;
  bool editable;
  final textCtl = TextEditingController();
  bool isShow = false;
  final String hintText;

  int totpCode = 0;
  double percent = 0.0;
  Timer timer;

  ContentTotpItemState({@required this.keyName, @required this.value, @required this.hintText, this.editable = false});

  @override
  void initState() {
    super.initState();
    textCtl.text = value;
    calculateTOTP();
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      calculateTOTP();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  calculateTOTP() {
    setState(() {
      var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      try {
        var textCtlValue = textCtl.text.replaceAll(' ', '');
        if (textCtlValue.length > 8) {
          totpCode = OTP.generateTOTPCode(textCtlValue, DateTime.now().millisecondsSinceEpoch,
            isGoogle: true,
            algorithm: Algorithm.SHA1,
          );
        } else {
          totpCode = 0;
        }
      } on FormatException catch(e) {
        print("error: ${e.toString()}.");
      } on Error catch(e) {
        print("error: ${e.toString()}.");
      }
      percent = (30 - currTime % 30) / 30;
    });
  }

  void setValue(String v) {
    setState(() {
      value = v;
      textCtl.text = value;
      calculateTOTP();
    });
  }

  void setEditable(bool v) {
    setState(() {
      editable = v;
      _textError = "";
    });
  }

  String _textError = "";
  setTextError(String value) {
    setState(() {
      _textError = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.0, horizontal: MediaQuery.of(context).size.width * 0.07),
      padding: EdgeInsets.all(7.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[100]))
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    keyName,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
              widget.obscureText?GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: 10.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset(isShow?'images/ic_eye.png':'images/ic_eye-slash.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  setState(() {
                    this.isShow = !this.isShow;
                  });
                },
              ):Container(),
              GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(right: editable&&widget.onCloseListener!=null?10.0:0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset('images/ic_copy.png', width: 14.0, height: 14.0),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                },
              ),
              editable&&widget.onCloseListener!=null?GestureDetector(
                child: Container(
                  width: 25.0,
                  height: 25.0,
                  margin: EdgeInsets.only(),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))
                  ),
                  child: Image.asset('images/ic_close.png', width: 14.0, height: 14.0),
                ),
                onTap: widget.onCloseListener,
              ):Container(),
            ],
          ),
          editable?Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
            decoration: BoxDecoration(
              color: const Color(0xfff2f4f8),
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: CupertinoTextField(
                    controller: textCtl,
                    obscureText: widget.obscureText?!isShow:false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    onChanged: widget.onChange,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _textError,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    alignment: Alignment.center,
                    child: Icon(
                      IconFonts.camera,
                      size: 18.0,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () async {
                    if (await Permission.camera.request().isGranted) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QrScanner(
                        callback: (code) {
                          if (code.startsWith("otpauth://")) {
                            var startIndex = code.indexOf("secret=", code.indexOf("?")) + 7;
                            var endIndex = code.indexOf("&", startIndex);
                            code = code.substring(startIndex, endIndex);
                          }
                          textCtl.text = code;
                          if (widget.onChange != null) {
                            widget.onChange(code);
                          }
                          setState((){});
                        },
                      )));
                    }
                  },
                ),
              ],
            ),
          ):Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 20.0,
                  ),
                  margin: EdgeInsets.only(bottom: 0.0),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: !widget.obscureText||isShow?Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[700],
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: Colors.grey[700],
                      ),
                    )),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            padding: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(
                Radius.circular(2.0),
              ),
            ),
            child: LinearProgressIndicator(
              value: percent,
              valueColor: AlwaysStoppedAnimation(Colors.black54),
              backgroundColor: const Color(0x00000000),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode ~/ 100000).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 100000 ~/ 10000).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 10000 ~/ 1000).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 1000 ~/ 100).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 100 ~/ 10).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 10).toString(),
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.all(Radius.circular(3.0))
                        ),
                        child: Image.asset('images/ic_copy.png', width: 14.0, height: 14.0),
                      ),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: totpCode.toString()));
                        showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}