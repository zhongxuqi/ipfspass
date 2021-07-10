import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContentInfo {
  String content_id;
  String encrypted_data;
  int last_modify_time;

  ContentInfo(this.content_id, this.encrypted_data, this.last_modify_time);
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
              "`content_id` varchar(256) NOT NULL UNIQUE, "+
              "`encrypted_data` text NOT NULL, "+
              "`last_modify_time` bigint NUT NULL"+
              ")");
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await db.execute("DROP TABLE ContentInfo");
          await db.execute("CREATE TABLE ContentInfo ("+
              "`id` integer NOT NULL PRIMARY KEY autoincrement, "+
              "`content_id` varchar(256) NOT NULL UNIQUE, "+
              "`encrypted_data` text NOT NULL, "+
              "`last_modify_time` bigint NUT NULL"+
              ")");
        });
    this.isInited = true;
  }

  upsertContentInfo(ContentInfo contentInfo) async {
    await this.database.transaction((txn) async {
      List<Map> list = await txn.rawQuery('SELECT * FROM ContentInfo WHERE `content_id` = ?', [contentInfo.content_id]);
      if (list.length == 0) {
        int id = await txn.rawInsert(
            'INSERT INTO ContentInfo(`content_id`, `encrypted_data`, `last_modify_time`) VALUES(?, ?, ?)',
            [contentInfo.content_id, contentInfo.encrypted_data, contentInfo.last_modify_time]);
        print("inserted: $id");
      } else {
        int count = await txn.rawUpdate(
            'UPDATE ContentInfo SET `encrypted_data` = ?, `last_modify_time` = ? WHERE `content_id` = ?',
            [contentInfo.encrypted_data, contentInfo.last_modify_time, contentInfo.content_id]);
        print("updated: $count");
      }
    });
  }

  insertContentInfo(ContentInfo contentInfo) async {
    await this.database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO ContentInfo(`content_id`, `encrypted_data`, `last_modify_time`) VALUES(?, ?, ?)',
          [contentInfo.content_id, contentInfo.encrypted_data, contentInfo.last_modify_time]);
      print("inserted: $id");
    });
  }

  updateContentInfo(ContentInfo contentInfo) async {
    await this.database.transaction((txn) async {
      int count = await txn.rawUpdate(
          'UPDATE ContentInfo SET `encrypted_data` = ?, `last_modify_time` = ? WHERE `content_id` = ?',
          [contentInfo.encrypted_data, contentInfo.last_modify_time, contentInfo.content_id]);
      print("updated: $count");
    });
  }

  getContentInfo(String contentID) async {
    List<Map> list = await this.database.rawQuery('SELECT * FROM ContentInfo WHERE `content_id` = ?', [contentID]);
    if (list.length == 0) {
      return null;
    }
    return ContentInfo(list[0]['content_id'], list[0]['encrypted_data'], list[0]['last_modify_time']);
  }

  deleteContentInfo(String contentID) async {
    await this.database.transaction((txn) async {
      int count = await txn.rawDelete('DELETE FROM ContentInfo WHERE `content_id` = ?', [contentID]);
      print("deleted: $count");
    });
  }

  deleteAllContentInfo() async {
    await this.database.transaction((txn) async {
      int count = await txn.rawDelete('DELETE FROM ContentInfo');
      print("deleted: $count");
    });
  }

  Future<List<ContentInfo>> listContentInfo(String account, int version) async {
    List<Map> list = await this.database.rawQuery('SELECT * FROM ContentInfo ORDER BY id DESC');
    List<ContentInfo> contentList = <ContentInfo>[];
    for (var item in list) {
      contentList.add(ContentInfo(item['content_id'], item['encrypted_data'], item['last_modify_time']));
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