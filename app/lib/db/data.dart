import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class ContentExtra {

  String toJSON() {
    var m = Map<String, dynamic>();
    return json.encode(m);
  }

  static ContentExtra fromJSON(String str) {
    var extra = ContentExtra();
    // Map<String, dynamic> m = json.decode(utf8.decode(str.codeUnits));
    return extra;
  }
}

class ContentInfo {
  int id;
  String content_id;
  String encrypted_data;
  ContentExtra extra;
  int last_modify_time;

  ContentInfo(this.id, this.content_id, this.encrypted_data, this.extra, this.last_modify_time);
}

class DataModal {
  var isInited;
  Database database;

  DataModal() {
    this.isInited = false;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "ipfspass.db");
    this.database = await openDatabase(path, version: 2,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE ContentInfo ("+
              "`id` integer NOT NULL PRIMARY KEY autoincrement, "+
              "`content_id` varchar(512) NOT NULL, "+
              "`encrypted_data` text NOT NULL, "+
              "`extra` text NOT NULL, "+
              "`last_modify_time` bigint NUT NULL"+
              ")");
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await db.execute("DROP TABLE ContentInfo");
          await db.execute("CREATE TABLE ContentInfo ("+
              "`id` integer NOT NULL PRIMARY KEY autoincrement, "+
              "`content_id` varchar(512) NOT NULL, "+
              "`encrypted_data` text NOT NULL, "+
              "`extra` text NOT NULL, "+
              "`last_modify_time` bigint NUT NULL"+
              ")");
        });
    this.isInited = true;
  }

  upsertContentInfo(ContentInfo contentInfo, ValueChanged<int> callback) async {
    await this.database.transaction((txn) async {
      List<Map> list = <Map>[];
      if (contentInfo.id != null) {
        list = await txn.rawQuery('SELECT * FROM ContentInfo WHERE `id` = ?', [contentInfo.id]);
      }
      if (list.length == 0) {
        var id = await txn.rawInsert(
            'INSERT INTO ContentInfo(`content_id`, `encrypted_data`, `extra`, `last_modify_time`) VALUES(?, ?, ?, ?)',
            [contentInfo.content_id, contentInfo.encrypted_data, contentInfo.extra.toJSON(), contentInfo.last_modify_time]);
        callback(id);
        print("inserted: $id");
      } else {
        int count = await txn.rawUpdate(
            'UPDATE ContentInfo SET `content_id` = ?, `encrypted_data` = ?, `extra` = ?, `last_modify_time` = ? WHERE `id` = ?',
            [contentInfo.content_id, contentInfo.encrypted_data, contentInfo.extra.toJSON(), contentInfo.last_modify_time, contentInfo.id]);
        callback(contentInfo.id);
        print("updated: $count");
      }
    });
  }

  updateContentInfo(ContentInfo contentInfo) async {
    await this.database.transaction((txn) async {
      int count = await txn.rawUpdate(
          'UPDATE ContentInfo SET `content_id` = ?, `encrypted_data` = ?, `last_modify_time` = ? WHERE `id` = ?',
          [contentInfo.content_id, contentInfo.encrypted_data, contentInfo.last_modify_time, contentInfo.id]);
      print("updated: $count");
    });
  }

  getContentInfo(int id) async {
    List<Map> list = await this.database.rawQuery('SELECT * FROM ContentInfo WHERE `id` = ?', [id]);
    if (list.length == 0) {
      return null;
    }
    return ContentInfo(list[0]['id'], list[0]['content_id'], list[0]['encrypted_data'], ContentExtra.fromJSON(list[0]['extra']), list[0]['last_modify_time']);
  }

  deleteContentInfo(int id) async {
    await this.database.transaction((txn) async {
      int count = await txn.rawDelete('DELETE FROM ContentInfo WHERE `id` = ?', [id]);
      print("deleted: $count");
    });
  }

  deleteAllContentInfo() async {
    await this.database.transaction((txn) async {
      int count = await txn.rawDelete('DELETE FROM ContentInfo');
      print("deleted: $count");
    });
  }

  Future<List<ContentInfo>> listContentInfo() async {
    List<Map> list = await this.database.rawQuery('SELECT * FROM ContentInfo ORDER BY id DESC');
    List<ContentInfo> contentList = <ContentInfo>[];
    for (var item in list) {
      contentList.add(ContentInfo(item['id'], item['content_id'], item['encrypted_data'], ContentExtra.fromJSON(item['extra']), item['last_modify_time']));
    }
    return contentList;
  }
}

DataModal instance = null;

DataModal getDataModel() {
  if (instance == null) {
    instance = new DataModal();
  }
  return instance;
}

void InitDB() async {
  var ins = getDataModel();
  ins.initDB();
}