import 'package:flutter/services.dart';

const platform = const MethodChannel('ipfspass.tech');

sha256(String data) async {
  var result = await platform.invokeMethod('sha256', {
    'data': data,
  });
  return result.toString();
}

encryptData(String masterPassword, String rawData) async {
  try {
    var result = await platform.invokeMethod('encryptData', {
      'masterPassword': masterPassword,
      'rawData': rawData,
    });
    return result.toString();
  } on PlatformException catch (e) {
    print("error: ${e.message}.");
  }
}

decryptData(String masterPassword, String encryptedData) async {
  try {
    var result = await platform.invokeMethod('decryptData', {
      'masterPassword': masterPassword,
      'encryptedData': encryptedData,
    });
    return result.toString();
  } on PlatformException catch (e) {
    print("error: ${e.message}.");
  }
}
