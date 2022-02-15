import 'package:flutter/material.dart';
import '../utils/iconfonts.dart';
import '../utils/colors.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback confirmCallback;
  final Text rightButtonText;

  TopBar({this.title="", this.confirmCallback, this.rightButtonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        border: const Border(bottom: const BorderSide(color: ColorUtils.divider)),
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: ColorUtils.white,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  child: Icon(
                    IconFonts.arrowLeft,
                    size: 24.0,
                    color: ColorUtils.textColor,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              confirmCallback!=null?InkWell(
                child: Container(
                  height: 40.0,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                  child: rightButtonText,
                ),
                onTap: () {
                  confirmCallback();
                },
              ):Container(),
            ],
          ),
        ],
      ),
    );
  }
}