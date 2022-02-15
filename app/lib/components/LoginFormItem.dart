import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoginFormItem extends StatelessWidget {
  final IconData iconData;
  final String hintText;
  final String errText;
  final ValueChanged<String> onChanged;
  final TextEditingController textEditCtl;
  final bool obscureText;
  final int maxLines;

  LoginFormItem({Key key, @required this.iconData, @required this.hintText, @required this.textEditCtl,
    @required this.onChanged, @required this.errText, this.obscureText=false, this.maxLines = 1}): super(key: key);

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorUtils.themeLightColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 8.0, left: 8.0, right: 0.0, bottom: 8.0),
            child: Icon(
              iconData,
              color: ColorUtils.blue,
              size: 25.0,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: 36,
              child: TextField(
                controller: textEditCtl,
                maxLines: maxLines,
                minLines: maxLines==null?2:1,
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
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  textBaseline: TextBaseline.alphabetic,
                ),
                onChanged: this.onChanged,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 8.0),
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