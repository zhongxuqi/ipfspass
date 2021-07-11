import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoginFormItem extends StatelessWidget {
  final IconData iconData;
  final String hintText;
  final String errText;
  final ValueChanged<String> onChanged;
  final TextEditingController textEditCtl;
  final bool obscureText;

  LoginFormItem({Key key, @required this.iconData, @required this.hintText, @required this.textEditCtl,
    @required this.onChanged, @required this.errText, this.obscureText=false}): super(key: key);

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff2f4f8),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(6.0),
            child: Icon(
              iconData,
              color: Colors.black54,
              size: 25.0,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: CupertinoTextField(
                obscureText: obscureText,
                controller: textEditCtl,
                scrollPadding: const EdgeInsets.all(0.0),
                placeholder: hintText,
                placeholderStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 15.0,
                  textBaseline: TextBaseline.alphabetic,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15.0,
                  textBaseline: TextBaseline.alphabetic,
                ),
                onChanged: (newText) {
                  this.onChanged(newText);
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 5.0),
            child: Text(
              errText,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}