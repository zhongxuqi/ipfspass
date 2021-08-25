import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'components/ContentTopbar.dart';
import 'utils/iconfonts.dart';
import 'utils/localization.dart';
import 'utils/content.dart';
import 'db/data.dart';
import 'common/types.dart';
import 'components/toast.dart';
import 'utils/ipfs.dart';
import 'utils/store.dart';
import 'components/AddKeyDialog.dart';
import 'utils/colors.dart';
import 'components/LoadingDialog.dart';
import 'components/ContentItem.dart';

class ContentPage extends StatefulWidget {
  final VoidCallback refreshCallback;
  final int id;
  final int contentType;
  final String tagName;

  ContentPage({Key key, this.id, @required this.contentType, @required this.refreshCallback, @required this.tagName}):super(key: key);

  @override
  State<StatefulWidget> createState() => ContentPageState(
    id: this.id,
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
  int id;

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

  ContentPageState({this.id, this.contentType, @required this.refreshCallback, @required this.tagName});

  @override
  initState() {
    super.initState();
    editable = id == null;
    getContentDetail();
  }

  getContentDetail() async {
    if (id != null) {
      var instance = getDataModel();
      var contentInfo = await instance.getContentInfo(id);
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
    var contentDetail = ContentDetail(id, "", currTime, ContentExtra(), title, content, contentType, this.account, newExtra, tags);
    var masterPassword = await StoreUtils.getMasterPassword();
    var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
    await getDataModel().upsertContentInfo(contentInfo, (id) async {
      contentInfo.id = id;
      this.refreshCallback();
      this.id = contentInfo.id;
      contentDetail.id = this.id;
      this.contentDetail = contentDetail;
      setEditable(false);
      renderContentDetail();
      if (await StoreUtils.getAutoUploadIPFS()) {
        uploadIPFS();
      }
    });
    isSubmitting = false;
  }

  void uploadIPFS() async {
    showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('upload_ipfs'));
    var masterPassword = await StoreUtils.getMasterPassword();
    var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
    IPFSUtils.uploadIPFS(contentInfo.encrypted_data).then((resp) async {
      contentDetail.content_id = resp.data['Name'];
      var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
      await getDataModel().upsertContentInfo(contentInfo, (id) {
        setState(() {});
      });
      Navigator.of(context).pop();
      this.refreshCallback();
      setState(() {});

      // 判断是否需要自动同步
      if (await StoreUtils.getAutoBackupContent()) {
        backupContent(context);
      }
    }).catchError((e) {
      Navigator.of(context).pop();
    });
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
          obscureText: true,
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
        obscureText: true,
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
              color: ColorUtils.green,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Text(
              AppLocalizations.of(context).getLanguageText('add_key'),
              style: TextStyle(
                color: ColorUtils.white,
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
      backgroundColor: ColorUtils.themeDarkColor,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Stack(
          children: <Widget>[
            ContentTopBar(
              contentType: contentType,
              actions: this.editable?<ContentTopBarAction>[
                this.id==null?null:ContentTopBarAction(
                  text: Text(
                    AppLocalizations.of(context).getLanguageText('cancel'),
                    style: TextStyle(
                      color: ColorUtils.orange,
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
                      color: ColorUtils.green,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onClickListener: submit,
                ),
              ]:<ContentTopBarAction>[
                if (contentDetail != null && (contentDetail.content_id == null || contentDetail.content_id.isEmpty)) ContentTopBarAction(
                  text: Icon(
                    IconFonts.upload,
                    color: ColorUtils.orange,
                    size: 25.0,
                  ),
                  onClickListener: () {
                    uploadIPFS();
                  },
                ),
                ContentTopBarAction(
                  text: Text(
                    AppLocalizations.of(context).getLanguageText('edit'),
                    style: TextStyle(
                      color: ColorUtils.blue,
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
