import 'package:dio/dio.dart';

class IPFSUtils {
  static Future<Response> uploadIPFS(String data) async {
    var dio = Dio();
    var formData = FormData.fromMap({
      'file': MultipartFile.fromString(data),
    });
    return dio.post('https://infura-ipfs.io:5001/api/v0/add?hash=sha2-256&inline-limit=32', data: formData).timeout(Duration(seconds: 5));
  }
}