import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FormInput extends StatelessWidget {
  final String keyName;
  final TextEditingController valueCtl;
  final bool isMultiLine;
  final String hintText;
  final ValueChanged<String> onchange;
  final String errText;

  FormInput({Key key, @required this.keyName, @required this.valueCtl, this.isMultiLine = false,
    @required this.hintText, @required this.onchange, @required this.errText}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10, right: 10.0, top: 10.0, bottom: 5.0),
          child: Text(
            keyName,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 36,
          margin: EdgeInsets.symmetric(horizontal: 10.0),
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
                child: TextField(
                  controller: valueCtl,
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
                  onChanged: this.onchange,
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
        )
      ],
    );
  }
}