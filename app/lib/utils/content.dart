import 'package:app/utils/store.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import '../db/data.dart';
import 'dart:async';
import 'encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import '../utils/localization.dart';
import '../components/AlertDialog.dart';

class ContentDetail {
  int id;
  String content_id;
  int last_modify_time;
  ContentExtra contentExtra;

  String title;
  String content;
  int type;
  String account;
  Map<String, dynamic> extra;
  List<String> tags;

  ContentDetail(this.id, this.content_id, this.last_modify_time, this.contentExtra, this.title, this.content, this.type, this.account, this.extra, this.tags);
}

Future<ContentInfo> convert2ContentInfo(String masterPassword, ContentDetail contentDetail) async {
  var encryptedData = await encrypt.encryptData(masterPassword, json.encode({
    'title': contentDetail.title,
    'content': contentDetail.content,
    'type': contentDetail.type,
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
    decryptedData['title'], decryptedData['content'], decryptedData['type'], decryptedData['account'],
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

class ContentBackup {
  final String encryptedMasterPassword;
  final List<ContentInfo> contents;

  Map<String, dynamic> toMap() {
    var contentMaps = <Map<String, dynamic>>[];
    for (var contentItem in contents) {
      contentMaps.add({
        'content_id': contentItem.content_id,
        'encrypted_data': contentItem.encrypted_data,
        'extra': contentItem.extra.toJSON(),
      });
    }
    return {
      "encrypted_master_password": encryptedMasterPassword,
      'contents': contentMaps,
    };
  }

  ContentBackup({@required this.encryptedMasterPassword, @required this.contents});

  static ContentBackup fromMap(Map<String, dynamic> data) {
    var encryptedMasterPassword = data['encrypted_master_password'];
    var contents = <ContentInfo>[];
    if (data['contents'] != null) {
      for (var item in data['contents']) {
        contents.add(ContentInfo(null, item['content_id'], item['encrypted_data'], ContentExtra(), null));
      }
    }
    return ContentBackup(encryptedMasterPassword: encryptedMasterPassword, contents: contents);
  }
}

void backupContent(BuildContext ctx) async {
  showAlertDialog(ctx, AppLocalizations.of(ctx).getLanguageText('backup_content_alert'), callback: () async {
    var encryptedMasterPassword = await StoreUtils.getRawMasterPassword();
    var instance = getDataModel();
    var contents = await instance.listContentInfo();
    var contentBackup = ContentBackup(encryptedMasterPassword: encryptedMasterPassword, contents: contents);
    var filesPath = path.join((await path_provider.getApplicationDocumentsDirectory()).path, 'ipfspass_backup.json');
    var file = File(filesPath);
    if (file.existsSync()) {
      file.deleteSync(recursive: true);
    }
    file.createSync(recursive: true);
    file.writeAsStringSync(json.encode(contentBackup.toMap()));
    Share.shareFiles(<String>[filesPath], mimeTypes: <String>["application/json"]);
  });
}

class ContentMessage {
  final String hint;
  final String passwordHash;
  final String encryptedData;

  ContentMessage({@required this.hint, @required this.passwordHash, @required this.encryptedData});

  String toJSON() {
    return json.encode({
      "hint": hint,
      "password_hash": passwordHash,
      "encrypted_data": encryptedData,
    });
  }

  static ContentMessage fromJSON(String jsonStr) {
    var dataMap = json.decode(jsonStr);
    return ContentMessage(hint: dataMap["hint"], passwordHash: dataMap["password_hash"], encryptedData: dataMap["encrypted_data"]);
  }
}