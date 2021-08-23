import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/iconfonts.dart';
import '../utils/localization.dart';
import 'toast.dart';

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