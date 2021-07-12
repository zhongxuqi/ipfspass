import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _languageTextMap = {
    "master_password": {
      "en": "Master Password",
      "zh": "主密码",
    },
    "init_master_password": {
      "en": "Init master password",
      "zh": "设置主密码",
    },
    "register_masterpassword_hint": {
      "en": "Please Input Master Password",
      "zh": "请输入主密码",
    },
    "register_remasterpassword_hint": {
      "en": "Please ReInput Master Password",
      "zh": "请重复输入主密码",
    },
    "clear_data_alert": {
      "en": "Are you sure to clear local data?",
      "zh": "是否确定清除本地数据？",
    },
    "cancel": {
      "en": "Cancel",
      "zh": "取消"
    },
    "confirm": {
      "en": "Confirm",
      "zh": "确定"
    },
    "wrong_masterpassword": {
      "en": "Wrong Master Password",
      "zh": "主密码错误",
    },
    "required": {
      "en": "required",
      "zh": "必填",
    },
    "repeat_error": {
      "en": "repeat error",
      "zh": "不一致",
    },
    "input_masterpassword_hint": {
      "en": "Please Input Master Password",
      "zh": "请输入主密码",
    },
    "fingerprint_hint": {
      "en": "Scan your fingerprint to authenticate",
      "zh": "请通过指纹认证",
    },
    "keyword_hint": {
      "en": "Please Input Keyword",
      "zh": "请输入关键字",
    },
  };

  String getLanguageText(String textID) {
    return _languageTextMap[textID][locale.languageCode];
  }

  String getLanguage() {
    return locale.languageCode;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
