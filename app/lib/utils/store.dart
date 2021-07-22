import 'package:shared_preferences/shared_preferences.dart';
import './encrypt.dart' as encrypt;
import '../common/types.dart' as types;

class StoreUtils {
  static const String EasyPass = "easypass";
  static const String MasterPasswordKey = "master_password";

  static setMasterPassword(String masterPassword) async {
    var sharedPreference = await SharedPreferences.getInstance();
    var encryptedMasterPassword = await encrypt.encryptData(EasyPass, masterPassword);
    sharedPreference.setString(MasterPasswordKey, encryptedMasterPassword);
  }

  static Future<String> getMasterPassword() async {
    var sharedPreference = await SharedPreferences.getInstance();
    var encryptedMasterPassword = sharedPreference.getString(MasterPasswordKey);
    if (encryptedMasterPassword == null) {
      return "";
    }
    return await encrypt.decryptData(EasyPass, encryptedMasterPassword);
  }

  static const SortByKey = 'sort-by';
  static setSortByKey(types.SortBy sortBy) async {
    var sharedPreference = await SharedPreferences.getInstance();
    switch (sortBy) {
      case types.SortBy.name:
        sharedPreference.setInt(SortByKey, 1);
        break;
      case types.SortBy.time:
        sharedPreference.setInt(SortByKey, 2);
        break;
    }
  }
  static Future<types.SortBy> getSortByKey() async {
    var sharedPreference = await SharedPreferences.getInstance();
    switch (sharedPreference.getInt(SortByKey)) {
      case 1:
        return types.SortBy.name;
      case 2:
        return types.SortBy.time;
    }
    return types.SortBy.time;
  }

  static const SortTypeKey = 'sort-type';
  static setSortTypeKey(types.SortType sortType) async {
    var sharedPreference = await SharedPreferences.getInstance();
    switch (sortType) {
      case types.SortType.asc:
        sharedPreference.setInt(SortTypeKey, 1);
        break;
      case types.SortType.desc:
        sharedPreference.setInt(SortTypeKey, 2);
        break;
    }
  }
  static Future<types.SortType> getSortTypeKey() async {
    var sharedPreference = await SharedPreferences.getInstance();
    switch (sharedPreference.getInt(SortTypeKey)) {
      case 1:
        return types.SortType.asc;
      case 2:
        return types.SortType.desc;
    }
    return types.SortType.desc;
  }

  static const LockScreenKey = "lock_screen";
  static setLockScreen(int timeout) async {
    var sharedPreference = await SharedPreferences.getInstance();
    sharedPreference.setInt(LockScreenKey, timeout);
  }
  static Future<int> getLockScreen() async {
    var sharedPreference = await SharedPreferences.getInstance();
    var t = sharedPreference.getInt(LockScreenKey);
    if (t == null) return 30;
    return t;
  }
}