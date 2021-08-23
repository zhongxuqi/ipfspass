import 'package:dio/dio.dart';

class IPFSUtils {
  static Future<Response> uploadIPFS(String data) async {
    // todo 获取gateway
    var dio = Dio();
    var formData = FormData.fromMap({
      'file': MultipartFile.fromString(data),
    });
    return dio.post('https://infura-ipfs.io:5001/api/v0/add?hash=sha2-256&inline-limit=32', data: formData).timeout(Duration(seconds: 5));
  }

  static Future<Response> convertIPFSContentID(String contentID) async {
    var dio = Dio();
    return dio.get('https://ipfs.easypass.tech/api/ipfs/cid/base32', queryParameters: {'arg': contentID}).timeout(Duration(seconds: 5));
  }

  static Future<Response> downloadFromIPFS(String contentID) async {
    // todo 获取gateway
    var url = "https://ipfs.io/ipfs/<cidv1>".replaceAll("<cidv1>", contentID);
    print("===>>> url $url");
    var dio = Dio();
    return dio.get(url).timeout(Duration(seconds: 5));
  }
}