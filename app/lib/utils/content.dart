import '../db/data.dart';
import 'dart:async';
import 'encrypt.dart' as encrypt;
import 'dart:convert';

class ContentDetail {
  int id;
  String content_id;
  int last_modify_time;
  ContentExtra contentExtra;

  String title;
  String content;
  String color;
  int type;
  String account;
  Map<String, dynamic> extra;
  List<String> tags;

  ContentDetail(this.id, this.content_id, this.last_modify_time, this.contentExtra, this.title, this.content, this.color, this.type, this.account, this.extra, this.tags);
}

Future<ContentInfo> convert2ContentInfo(String masterPassword, ContentDetail contentDetail) async {
  var encryptedData = await encrypt.encryptData(masterPassword, json.encode({
    'title': contentDetail.title,
    'content': contentDetail.content,
    'type': contentDetail.type,
    'color': contentDetail.color,
    'account': contentDetail.account,
    'extra': contentDetail.extra,
    'tags': contentDetail.tags,
  }));
  return ContentInfo(contentDetail.id, contentDetail.content_id, encryptedData, contentDetail.contentExtra, contentDetail.last_modify_time);
}

Future<ContentDetail> convert2ContentDetail(String masterPassword, ContentInfo contentInfo) async {
  var decryptedDataStr = await encrypt.decryptData(masterPassword, contentInfo.encrypted_data);
  if (decryptedDataStr == "") return null;
  Map<String, dynamic> decryptedData = json.decode(decryptedDataStr);
  List<String> tagList = <String>[];
  if (decryptedData['tags'] is List) {
    for (var tag in decryptedData['tags']) {
      if (tag is String) {
        tagList.add(tag);
      }
    }
  }
  return ContentDetail(contentInfo.id, contentInfo.content_id, contentInfo.last_modify_time, contentInfo.extra,
    decryptedData['title'], decryptedData['content'], decryptedData['color'], decryptedData['type'], decryptedData['account'],
      decryptedData['extra']==null?Map<String, dynamic>():decryptedData['extra'], tagList);
}

Future<List<ContentDetail>> listContentDetail(masterPassword, int type) async {
  var instance = getDataModel();
  var contentInfoList = await instance.listContentInfo();
  var contentDetailList = <ContentDetail>[];
  for (var contentInfo in contentInfoList) {
    var contentDetail = await convert2ContentDetail(masterPassword, contentInfo);
    if (contentDetail == null) continue;
    if (type != 0 && type != contentDetail.type) {
      continue;
    }
    contentDetailList.add(contentDetail);
  }
  return contentDetailList;
}