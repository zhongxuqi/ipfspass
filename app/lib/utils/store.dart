import 'package:shared_preferences/shared_preferences.dart';
import './encrypt.dart' as encrypt;

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
}