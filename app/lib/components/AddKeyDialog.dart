import 'package:flutter/material.dart';
import '../utils/localization.dart';
import 'FormInput.dart';

void showAddKeyDialog(BuildContext context, {@required ValueChanged<String> callback,
  @required String keyName, @required String keyNameHint, @required initValue}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AddKey(
        callback: callback,
        keyName: keyName,
        keyNameHint: keyNameHint,
        initValue: initValue,
      );
    },
  );
}

class AddKey extends StatefulWidget {
  final ValueChanged<String> callback;
  final String keyName;
  final String keyNameHint;
  final String initValue;

  AddKey({Key key, @required this.callback, @required this.keyName, @required this.keyNameHint, @required this.initValue}): super(key: key);

  @override
  AddKeyState createState() => AddKeyState(
    callback: callback,
    keyName: keyName,
    keyNameHint: keyNameHint,
    initValue: initValue,
  );
}

class AddKeyState extends State<AddKey> {
  final ValueChanged<String> callback;
  final valueCtl = TextEditingController();
  final String keyName;
  final String keyNameHint;
  final String initValue;

  String errText = '';

  AddKeyState({@required this.callback, @required this.keyName, @required this.keyNameHint, @required this.initValue});

  @override
  void initState() {
    super.initState();
    valueCtl.text = initValue;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.only(bottom: 10),
      children: <Widget>[
        Container(
          child: FormInput(
            keyName: keyName,
            valueCtl: valueCtl,
            hintText: keyNameHint,
            onchange: (newText) {
              setState(() {
                errText = '';
              });
            },
            errText: errText,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 10, right: 10.0, top: 10.0, bottom: 0.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    padding: EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('cancel'),
                      style: TextStyle(
                        color: Colors.black,
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
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      AppLocalizations.of(context).getLanguageText('confirm'),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (valueCtl.text == '') {
                      setState(() {
                        errText = AppLocalizations.of(context).getLanguageText('required');
                      });
                    } else {
                      callback(valueCtl.text);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}