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
