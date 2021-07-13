import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TagCard extends StatelessWidget {
  final String tagIcon;
  final Color tagIconColor;
  final String tagName;
  final VoidCallback onClickListener;
  final VoidCallback onLongPressListener;

  TagCard({Key key, this.tagIcon, this.tagIconColor, @required this.tagName, @required this.onClickListener,
    this.onLongPressListener}): super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  color: tagIconColor==null?ColorUtils.getTagColor():tagIconColor,
                  borderRadius: BorderRadius.all(Radius.circular(999.0))
              ),
              child: Image.asset(tagIcon==null?'images/ic_tag.png':tagIcon, width: 16.0, height: 16.0),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 5.0, top: 13.0, bottom: 13.0),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]))
                ),
                child: Text(
                  tagName,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: const Color(0xff434343),
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