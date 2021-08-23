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
    "navigation": {
      "en": "Navigation",
      "zh": "导航",
    },
    "all_content": {
      "en": "All Content",
      "zh": "所有内容",
    },
    "secret_message": {
      "en": "Secret Message",
      "zh": "密信",
    },
    "personal": {
      "en": "Personal",
      "zh": "个人",
    },
    "sync_data": {
      "en": "Sync Data",
      "zh": "同步数据",
    },
    "modify_master_password": {
      "en": "Modify MasterPass",
      "zh": "修改主密码",
    },
    "logout": {
      "en": "Logout",
      "zh": "注销",
    },
    "settings": {
      "en": "Settings",
      "zh": "设置",
    },
    "feedback": {
      "en": "Feedback",
      "zh": "反馈",
    },
    "affirm_delete_content": {
      "en": 'Deleted data can\'t be recovery, are you sure?',
      "zh": '删除的数据无法恢复，您是否确定?',
    },
    "all_password": {
      "en": 'All Password',
      "zh": '所有密码',
    },
    "all_text": {
      "en": 'All Text',
      "zh": '所有文本',
    },
    "all_totp": {
      "en": 'All Google Auth',
      "zh": '所有Google认证',
    },
    "rename_tag": {
      "en": 'Rename tag',
      "zh": '重命名标签',
    },
    "processing": {
      "en": 'Processing...',
      "zh": '处理中...',
    },
    "tag_name": {
      "en": 'Tag Name',
      "zh": '标签名',
    },
    "tag_name_input_hint": {
      "en": 'Please input tag name...',
      "zh": '请输入标签名...',
    },
    "delete_tag": {
      "en": 'Delete Tag',
      "zh": '删除标签',
    },
    "remove_from_tag": {
      "en": 'Remove from tag',
      "zh": '从标签中移除',
    },
    "delete": {
      "en": 'Delete',
      "zh": '删除',
    },
    "add_tag": {
      "en": 'Add New Tag',
      "zh": '添加新标签',
    },
    "add_exists_content": {
      "en": 'Add exists content',
      "zh": '添加现有内容',
    },
    "add_password": {
      "en": 'Add New Password',
      "zh": '添加新密码',
    },
    "add_text": {
      "en": 'Add New Text',
      "zh": '添加新文本',
    },
    "add_totp": {
      "en": 'Add New Totp',
      "zh": '添加新谷歌认证',
    },
    "tag_name_exists": {
      "en": 'Tag exists',
      "zh": '已存在',
    },
    "content_required": {
      "en": 'require one content at least',
      "zh": '请至少选择一个内容',
    },
    "title": {
      "en": 'Title',
      "zh": '标题',
    },
    "input_title_hint": {
      "en": 'Please input title',
      "zh": '请输入标题',
    },
    "account": {
      "en": 'Account',
      "zh": '账户',
    },
    "input_account_hint": {
      "en": 'Please input account',
      "zh": '请输入帐号',
    },
    "password": {
      "en": 'Password',
      "zh": '密码',
    },
    "input_password_hint": {
      "en": 'Please input password',
      "zh": '请输入密码',
    },
    "text": {
      "en": 'Text',
      "zh": '文本',
    },
    "input_text_hint": {
      "en": 'Please input text',
      "zh": '请输入文本',
    },
    "totp": {
      "en": 'Google Auth',
      "zh": '谷歌验证',
    },
    "totp_key": {
      "en": 'Google Auth Key',
      "zh": '谷歌验证Key',
    },
    "input_totp_hint": {
      "en": 'Please input Google Auth',
      "zh": '请输入谷歌验证Key',
    },
    "input_hint": {
      "en": 'Please Input...',
      "zh": '请输入...',
    },
    "add_key": {
      "en": 'Add Key',
      "zh": '添加字段',
    },
    "key_exists": {
      "en": 'Key exists',
      "zh": '字段名已存在',
    },
    "key_name": {
      "en": 'Key Name',
      "zh": '字段名',
    },
    "key_name_hint": {
      "en": 'Please input key name',
      "zh": '请输入字段名',
    },
    "submit": {
      "en": 'Submit',
      "zh": '提交',
    },
    "edit": {
      "en": 'Edit',
      "zh": '编辑',
    },
    "copied": {
      "en": 'Copied',
      "zh": '复制成功',
    },
    "generate": {
      "en": 'Generate',
      "zh": '生成',
    },
    "sort_by": {
      "en": 'Sort By',
      "zh": '排序依据',
    },
    "sort_type": {
      "en": 'Sort Type',
      "zh": '排序类型',
    },
    "sort_by_name": {
      "en": 'Sort By Name',
      "zh": '按名称排序',
    },
    "sort_by_time": {
      "en": 'Sort By Time',
      "zh": '按时间排序',
    },
    "sort_type_asc": {
      "en": 'Ascending',
      "zh": '升序',
    },
    "sort_type_desc": {
      "en": 'Descending',
      "zh": '降序',
    },
    "reauth_timeout": {
      "en": 'Timeout to lock screen',
      "zh": '超时锁屏',
    },
    "second": {
      "en": 'Second',
      "zh": '秒',
    },
    "old_master_password": {
      "en": 'Old Master Password',
      "zh": '旧主密码',
    },
    "old_master_password_hint": {
      "en": 'Please Input Old Master Password',
      "zh": '请输入旧主密码',
    },
    "new_master_password": {
      "en": 'New Master Password',
      "zh": '新主密码',
    },
    "new_master_password_hint": {
      "en": 'Please Input New Master Password',
      "zh": '请输入新主密码',
    },
    "repeat_new_master_password": {
      "en": 'Repeat New Master Password',
      "zh": '重复新主密码',
    },
    "repeat_new_master_password_hint": {
      "en": 'Please Repeat Input New Master Password',
      "zh": '请重复输入新主密码',
    },
    "upload_ipfs": {
      "en": 'Upload IPFS',
      "zh": '上传IPFS',
    },
    "auto_upload_ipfs": {
      "en": "Auto upload IPFS",
      "zh": "自动上传IPFS",
    },
    "uploading": {
      "en": "Uploading...",
      "zh": "上传中..."
    },
    "auto_backup_content": {
      "en": "Auto backup content",
      "zh": "自动备份内容"
    },
    "backup_content_alert": {
      "en": "Whether to backup content",
      "zh": "是否备份内容"
    },
    "recover_data_from_backup_file": {
      "en": "Recover data from backup file",
      "zh": "从备份文件恢复数据"
    },
    "content_type": {
      "en": "Content Type",
      "zh": "内容类型"
    },
    "account_optional": {
      "en": "Account (Optional)",
      "zh": "账户（选填）"
    },
    "gonext": {
      "en": "Go Next",
      "zh": "下一步"
    },
    "goback": {
      "en": "Go Back",
      "zh": "上一步"
    },
    "temp_password": {
      "en": "Temporary Password",
      "zh": "临时加密密码"
    },
    "input_temp_pass_hint": {
      "en": "Please input temporary password",
      "zh": "请输入临时密码"
    },
    "message_hint_word": {
      "en": "Hint Word",
      "zh": "提示语"
    },
    "input_message_hint_word_hint": {
      "en": "Please input hint word",
      "zh": "请输入提示语"
    },
    "content_title": {
      "en": "Content Title",
      "zh": "内容标题"
    },
    "pack": {
      "en": "Pack",
      "zh": "打包"
    },
    "packing": {
      "en": "Packing...",
      "zh": "打包中..."
    },
    "pack_result": {
      "en": "Pack Result",
      "zh": "打包结果"
    },
    "copy_ipfs": {
      "en": "Copy IPFS Content ID",
      "zh": "拷贝IPFS内容ID"
    },
    "send_exist_password": {
      "en": "Send exist passord",
      "zh": "发送现有密码",
    },
    "send_new_password": {
      "en": "Send new passord",
      "zh": "发送新密码",
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
