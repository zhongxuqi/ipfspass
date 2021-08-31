import 'package:dio/dio.dart';

class IPFSUtils {
  static var dio = Dio();
  static String readGateway = "";
  static String writeGateway = "";

  static initGateway() async {
    if (readGateway.isNotEmpty && writeGateway.isNotEmpty) return;
    var response = await dio.get('https://ipfs.easypass.tech/api/ipfs').timeout(Duration(seconds: 5));
    if (response.data["errno"] != 0) {
      throw "init gateway final";
    }
    readGateway = response.data["data"]["read_gateway"][0];
    writeGateway = response.data["data"]["write_gateway"][0];
  }

  static Future<Response> uploadIPFS(String data) async {
    await initGateway();
    var formData = FormData.fromMap({
      'file': MultipartFile.fromString(data),
    });
    return dio.post('$writeGateway/api/v0/add?hash=sha2-256&inline-limit=32', data: formData).timeout(Duration(seconds: 5));
  }

  static Future<Response> convertIPFSContentID(String contentID) async {
    return dio.get('https://ipfs.easypass.tech/api/ipfs/cid/base32', queryParameters: {'arg': contentID}).timeout(Duration(seconds: 5));
  }

  static Future<String> getContentUrl(String contentIDV1) async {
    await initGateway();
    return readGateway.replaceAll("<cidv1>", contentIDV1);
  }

  static Future<Response> downloadFromIPFS(String contentIDV1) async {
    await initGateway();
    var url = await getContentUrl(contentIDV1);
    return dio.get(url).timeout(Duration(seconds: 10));
  }
}