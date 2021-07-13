import 'package:app/utils/colors.dart';
import 'package:flutter/material.dart';

class DrawerButton extends StatelessWidget {
  final String text;
  final IconData iconData;
  final bool isActive;
  final VoidCallback onClick;

  DrawerButton({Key key, @required this.text, @required this.iconData, @required this.isActive, @required this.onClick}):super(key: key);
  
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: const BoxConstraints(minHeight: 0.0, minWidth: 0.0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: isActive?ColorUtils.themeLightColor:ColorUtils.transparent,
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 18.0,
              margin: EdgeInsets.only(right: 7.0),
              child: Icon(
                iconData,
                size: 18.0,
                color: isActive?ColorUtils.white:ColorUtils.grey,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                fontSize: 13.0,
                color: isActive?ColorUtils.white:ColorUtils.grey,
              ),
            ),
          ],
        ),
      ),
      onPressed: onClick,
    );
  }
}