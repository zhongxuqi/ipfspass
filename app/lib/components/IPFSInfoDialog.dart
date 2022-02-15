import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'ContentItem.dart';
import '../utils/localization.dart';
import '../utils/ipfs.dart';
import 'Toast.dart';

void showIPFSInfoDialog(BuildContext context, {@required String contentID}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return IPFSInfoDialog(
        contentID: contentID,
      );
    },
  );
}

class IPFSInfoDialog extends StatefulWidget {
  final String contentID;

  IPFSInfoDialog({Key key, @required this.contentID}): super(key: key);

  @override
  IPFSInfoDialogState createState() => IPFSInfoDialogState();
}

class IPFSInfoDialogState extends State<IPFSInfoDialog> {
  final GlobalKey<ContentTextItemState> _contentURLKey = GlobalKey<ContentTextItemState>();
  String contentUrl = '';

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    IPFSUtils.convertIPFSContentID(widget.contentID).then((value) async {
      if (value.data["errno"] != 0) {
        showErrorToast(AppLocalizations.of(context).getLanguageText("network_error"));
        return;
      }
      String cidv1 = value.data["data"]["cid_v1"];
      this.contentUrl = await IPFSUtils.getContentUrl(cidv1);
      setState(() {});
      if (_contentURLKey.currentState != null) {
        _contentURLKey.currentState.setValue(contentUrl);
      }
    }).onError((e, s) {
      showErrorToast(AppLocalizations.of(context).getLanguageText("network_error"));
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formRows = <Widget>[];
    formRows.add(ContentTextItem(
      keyName: AppLocalizations.of(context).getLanguageText('ipfs_content_id'),
      value: widget.contentID,
      hintText: '',
      editable: false,
      onChange: (value) {},
      maxLines: null,
    ));
    formRows.add(ContentTextItem(
      key: _contentURLKey,
      keyName: AppLocalizations.of(context).getLanguageText('ipfs_content_url'),
      value: contentUrl,
      hintText: '',
      editable: false,
      onChange: (value) {},
      maxLines: null,
    ));
    return SimpleDialog(
      contentPadding: EdgeInsets.only(bottom: 10),
      backgroundColor: ColorUtils.themeDarkColor,
      children: formRows,
    );
  }
}