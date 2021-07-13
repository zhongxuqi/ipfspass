import 'package:flutter/material.dart';
import '../utils/iconfonts.dart';
import '../utils/colors.dart';
import '../common/types.dart';
import '../utils/localization.dart';

class ContentTopBarAction {
  final Text text;
  final VoidCallback onClickListener;

  ContentTopBarAction({@required this.text, @required this.onClickListener});
}

class ContentTopBar extends StatelessWidget {
  final int contentType;
  final List<ContentTopBarAction> actions;

  ContentTopBar({@required this.contentType, this.actions});

  @override
  Widget build(BuildContext context) {
    var tagIcon = 'images/ic_tag.png';
    var tagIconColor = ColorUtils.getTagColor();
    var title = "";
    switch (contentType) {
      case PasswordType:
        tagIcon = 'images/ic_key.png';
        tagIconColor = ColorUtils.getPasswordColor();
        title = AppLocalizations.of(context).getLanguageText('password');
        break;
      case TextType:
        tagIcon = 'images/ic_file-text.png';
        tagIconColor = ColorUtils.getTextColor();
        title = AppLocalizations.of(context).getLanguageText('text');
        break;
      case TOTPType:
        tagIcon = 'images/ic_stopwatch.png';
        tagIconColor = ColorUtils.getTotpColor();
        title = AppLocalizations.of(context).getLanguageText('totp');
        break;
    }
    List<Widget> actionWidgets = <Widget>[];
    if (actions != null) {
      actionWidgets.addAll(actions.map((item) {
        if (item == null) {
          return Container();
        }
        return InkWell(
          child: Container(
            height: 40.0,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
            child: item.text,
          ),
          onTap: item.onClickListener,
        );
      }).toList());
    }
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        border: const Border(bottom: const BorderSide(color: const Color(0xffe6ecff))),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 50.0,
              height: 50.0,
              child: Icon(
                IconFonts.arrowLeft,
                size: 24.0,
              ),
            ),
          ),
          Container(
            width: 30.0,
            height: 30.0,
            margin: EdgeInsets.only(right: 7.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: tagIconColor,
                borderRadius: BorderRadius.all(Radius.circular(999.0))
            ),
            child: Image.asset(tagIcon, width: 16.0, height: 16.0),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 5.0, top: 13.0, bottom: 13.0),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xff434343),
                ),
              ),
            ),
          ),
        ]..addAll(actionWidgets),
      ),
    );
  }
}