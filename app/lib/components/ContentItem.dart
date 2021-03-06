import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../utils/iconfonts.dart';
import '../utils/localization.dart';
import 'toast.dart';
import 'dart:async';
import "package:otp/otp.dart";
import 'package:permission_handler/permission_handler.dart';
import '../QrScanner.dart';
import 'dart:math';
import '../utils/colors.dart';

class ContentItem extends StatefulWidget {
  final String title;
  final String content;

  ContentItem({Key key, @required this.title, @required this.content}): super(key: key);

  @override
  createState() => _ContentItemState(
    title: title,
    content: content,
  );
}

class _ContentItemState extends State<ContentItem> {
  final String title;
  final String content;
  bool isShow = false;

  _ContentItemState({@required this.title, @required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 13.0, top: 13.0, bottom: 5.0),
          child: Text(
            title,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x30000000),
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(13.0),
                  child: Icon(
                    this.isShow
                        ? IconFonts.eye
                        : IconFonts.eyeslash,
                    size: 17.0,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  setState(() {
                    this.isShow = !this.isShow;
                  });
                },
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 0.0,vertical: 5.0),
                  child: isShow?Text(
                    content,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 0.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: Colors.white,
                      ),
                    )),
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.all(13.0),
                  child: Icon(
                    IconFonts.copy,
                    size: 17.0,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  showSuccessToast(AppLocalizations.of(context).getLanguageText('copied'));
                },
              ),
            ],
          ),
        )
      ],
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
          border: Border(bottom: BorderSide(color: ColorUtils.divider))
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
                      color: ColorUtils.textColor,
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
                      color: ColorUtils.blue,
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
                      color: ColorUtils.green,
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
                    controller: textCtl,
                    obscureText: widget.obscureText?!isShow:false,
                    maxLines: (widget.obscureText?isShow:true)?widget.maxLines:1,
                    minLines: widget.maxLines==null&&(widget.obscureText?isShow:true)?2:1,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: ColorUtils.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
                    ),
                    onChanged: widget.onChange,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 5.0),
                  child: Text(
                    _textError,
                    style: TextStyle(
                      color: ColorUtils.red,
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
                      color: ColorUtils.textColor,
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: ColorUtils.textColor,
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
            splashColor: ColorUtils.white,
            highlightColor: ColorUtils.white,
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
                  color: ColorUtils.white,
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
        border: Border(bottom: BorderSide(color: ColorUtils.divider)),
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
                      color: ColorUtils.white,
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
                      color: ColorUtils.blue,
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
                      color: ColorUtils.green,
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
            height: 38,
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
                    controller: textCtl,
                    obscureText: widget.obscureText?!isShow:false,
                    maxLines: widget.maxLines,
                    style: TextStyle(
                      color: ColorUtils.textColor,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: ColorUtils.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
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
                      color: ColorUtils.textColor,
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: ColorUtils.textColor,
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
          border: Border(bottom: BorderSide(color: ColorUtils.divider))
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
                      color: ColorUtils.textColor,
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
                      color: ColorUtils.blue,
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
                      color: ColorUtils.green,
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
                      color: ColorUtils.red,
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
              color: ColorUtils.themeLightColor,
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
                      color: ColorUtils.textColor,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    placeholder: hintText,
                    placeholderStyle: TextStyle(
                      color: ColorUtils.grey,
                      fontSize: 15.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                    decoration: BoxDecoration(
                      color: ColorUtils.themeLightColor,
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
                      color: ColorUtils.white,
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
                      color: ColorUtils.textColor,
                    ),
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List<Widget>.filled(8, Container(
                      margin: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        IconFonts.circle,
                        size: 7.0,
                        color: ColorUtils.textColor,
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
              color: ColorUtils.white,
              borderRadius: BorderRadius.all(
                Radius.circular(2.0),
              ),
            ),
            child: LinearProgressIndicator(
              value: percent,
              valueColor: AlwaysStoppedAnimation(ColorUtils.themeLightColor),
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode ~/ 100000).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 100000 ~/ 10000).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 10000 ~/ 1000).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 1000 ~/ 100).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 100 ~/ 10).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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
                        color: ColorUtils.themeLightColor,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                      ),
                      child: Text(
                        (totpCode % 10).toString(),
                        style: TextStyle(
                          color: ColorUtils.textColorGrey,
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