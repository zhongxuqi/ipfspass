import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_qr_reader/qrcode_reader_view.dart';

class QrScanner extends StatefulWidget {
  final ValueChanged<String> callback;

  QrScanner({Key key, this.callback}) : super(key: key);

  @override
  QrScannerState createState() => new QrScannerState(callback: callback);
}

class QrScannerState extends State<QrScanner> {
  GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();
  final ValueChanged<String> callback;

  QrScannerState({this.callback});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: QrcodeReaderView(
        key: qrViewKey,
        onScan: (String data) async {
          Navigator.of(context).pop();
          callback(data);
        },
      ),
    );
  }
}