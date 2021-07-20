import 'package:app/utils/content.dart';
import 'package:app/utils/iconfonts.dart';
import 'package:app/utils/store.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import '../common/types.dart';
import '../content.dart';
import 'AlertDialog.dart';
import 'package:app/utils/localization.dart';
import '../db/data.dart';
import '../utils/colors.dart';
import 'TagCard.dart';
import 'AddKeyDialog.dart';
import 'LoadingDialog.dart';
import 'FormInput.dart';
import 'Toast.dart';

class FragmentContent extends StatefulWidget {
  String keyword = '';
  final VoidCallback clearKeyWord;

  FragmentContent({Key key, @required this.clearKeyWord}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FragmentContentState(
      keyword: keyword,
      clearKeyWord: clearKeyWord,
    );
  }
}

class FragmentContentState extends State<FragmentContent> {
  final VoidCallback clearKeyWord;

  int level = 0;
  String tagName = '';
  int contentType = 0;
  List<ContentDetail> contentList = <ContentDetail>[];
  final GlobalKey<ModalAddState> _modalAddGlobalKey = GlobalKey<ModalAddState>();
  Map<String, List<ContentDetail>> tagContentMap = Map<String, List<ContentDetail>>();
  List<ContentDetail> passwordList = <ContentDetail>[];
  List<ContentDetail> textList = <ContentDetail>[];
  List<ContentDetail> totpList = <ContentDetail>[];
  List<ContentDetail> digitalWalletList = <ContentDetail>[];
  List<String> tags = <String>[];

  FragmentContentState({String keyword, @required this.clearKeyWord}) {
    _keyword = keyword;
  }

  String _keyword = '';
  String get keyword => _keyword;
  void setKeyword(String value) {
    setState(() {
      _keyword = value;
    });
  }

  @override
  initState() {
    super.initState();
    initContentList();
  }

  String preprocessTitle(String title) {
    return PinyinHelper.getPinyin(title, format: PinyinFormat.WITHOUT_TONE).replaceAll(' ', '').toLowerCase();
  }

  initContentList() async {
    var masterPassword = await StoreUtils.getMasterPassword();
    if (masterPassword == null) return;
    try {
      contentList = await listContentDetail(masterPassword, 0);
    } on Exception catch (e) {
      print("${e.toString()}");
      initContentList();
      return;
    }
    if (_modalAddGlobalKey.currentState != null) {
      _modalAddGlobalKey.currentState.contentList = contentList;
      _modalAddGlobalKey.currentState.setState(() {});
    }
    final sortBy = await StoreUtils.getSortByKey();
    final sortType = await StoreUtils.getSortTypeKey();
    if (sortBy == SortBy.time && sortType == SortType.asc) {
      contentList = contentList.reversed.toList();
    } else if (sortBy == SortBy.name) {
      contentList.sort((a, b) {
        int factor = 1;
        if (sortType == SortType.desc) {
          factor = -1;
        }
        return factor * preprocessTitle(a.title).compareTo(preprocessTitle(b.title));
      });
      contentList.sort((a, b) {
        int factor = 1;
        if (sortType == SortType.desc) {
          factor = -1;
        }
        return factor * preprocessTitle(a.title).compareTo(preprocessTitle(b.title));
      });
    }
    tagContentMap = Map<String, List<ContentDetail>>();
    passwordList = <ContentDetail>[];
    textList = <ContentDetail>[];
    totpList = <ContentDetail>[];
    digitalWalletList = <ContentDetail>[];
    tags = <String>[];
    for (ContentDetail contentItem in contentList) {
      switch (contentItem.type) {
        case PasswordType:
          passwordList.add(contentItem);
          break;
        case TextType:
          textList.add(contentItem);
          break;
        case TOTPType:
          totpList.add(contentItem);
          break;
      }
      for (String tagItem in contentItem.tags) {
        if (!tagContentMap.containsKey(tagItem)) {
          tagContentMap[tagItem] = List<ContentDetail>();
        }
        tagContentMap[tagItem].add(contentItem);
        if (tags.where((tagName) => tagName == tagItem).length <= 0) {
          tags.add(tagItem);
        }
      }
    }
    if (sortBy == SortBy.name) {
      tags.sort((a, b) {
        int factor = 1;
        if (sortType == SortType.desc) {
          factor = -1;
        }
        return factor * preprocessTitle(a).compareTo(preprocessTitle(b));
      });
      tags.sort((a, b) {
        int factor = 1;
        if (sortType == SortType.desc) {
          factor = -1;
        }
        return factor * preprocessTitle(a).compareTo(preprocessTitle(b));
      });
    }
    setState(() {});
  }

  void goBack() {
    setState(() {
      level = 0;
      contentType = 0;
      tagName = '';
    });
    clearKeyWord();
  }

  void onDeleteClick(ContentDetail contentDetail) {
    showAlertDialog(context, AppLocalizations.of(context).getLanguageText('affirm_delete_content'),
      callback: () async {
        var instance = getDataModel();
        await instance.deleteContentInfo(contentDetail.content_id);
        initContentList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ContentDetail> filterContentList;
    switch (contentType) {
      case PasswordType:
        filterContentList = passwordList;
        break;
      case TextType:
        filterContentList = textList;
        break;
      case TOTPType:
        filterContentList = totpList;
        break;
      default:
        if (tagContentMap.containsKey(tagName)) {
          filterContentList = tagContentMap[tagName];
        } else {
          level = 0;
          contentType = 0;
          tagName = '';
          // filterContentList = contentList;
        }
        break;
    }
    Widget w;
    switch (level) {
      case 0:
        w = CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[
                  _keyword==''||AppLocalizations.of(context).getLanguageText('all_password').toLowerCase().contains(_keyword.toLowerCase())?TagCard(
                    tagIcon: 'images/ic_key.png',
                    tagIconColor: ColorUtils.getPasswordColor(),
                    tagIconBgColor: ColorUtils.getPasswordBgColor(),
                    tagName: AppLocalizations.of(context).getLanguageText('all_password'),
                    onClickListener: () async {
                      tagName = '';
                      contentType = PasswordType;
                      setState(() {
                        level = 1;
                      });
                      clearKeyWord();
                    },
                  ):Container(),
                  _keyword==''||AppLocalizations.of(context).getLanguageText('all_text').toLowerCase().contains(_keyword.toLowerCase())?TagCard(
                    tagIcon: 'images/ic_file-text.png',
                    tagIconColor: ColorUtils.getTextColor(),
                    tagIconBgColor: ColorUtils.getTextBgColor(),
                    tagName: AppLocalizations.of(context).getLanguageText('all_text'),
                    onClickListener: () async {
                      tagName = '';
                      contentType = TextType;
                      setState(() {
                        level = 1;
                      });
                      clearKeyWord();
                    },
                  ):Container(),
                  _keyword==''||AppLocalizations.of(context).getLanguageText('all_totp').toLowerCase().contains(_keyword.toLowerCase())?TagCard(
                    tagIcon: 'images/ic_stopwatch.png',
                    tagIconColor: ColorUtils.getTotpColor(),
                    tagIconBgColor: ColorUtils.getTotpBgColor(),
                    tagName: AppLocalizations.of(context).getLanguageText('all_totp'),
                    onClickListener: () async {
                      tagName = '';
                      contentType = TOTPType;
                      setState(() {
                        level = 1;
                      });
                      clearKeyWord();
                    },
                  ):Container(),
                ]..addAll(tags.where((tagItem) {
                  if (tagItem.toLowerCase().contains(_keyword.toLowerCase())) {
                    return true;
                  }
                  return false;
                }).map((tagName) {
                  return TagCard(
                    tagIcon: 'images/ic_tag.png',
                    tagIconColor: ColorUtils.getTagColor(),
                    tagName: tagName,
                    onClickListener: () async {
                      this.tagName = tagName;
                      contentType = 0;
                      setState(() {
                        level = 1;
                      });
                      clearKeyWord();
                    },
                    onLongPressListener: () async {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext ctx) {
                          return SimpleDialog(
                            contentPadding: EdgeInsets.only(),
                            children: <Widget>[
                              ActionItem(
                                icon: 'images/ic_edit.png',
                                color: Colors.blue,
                                text: AppLocalizations.of(context).getLanguageText('rename_tag'),
                                onClickListener: () async {
                                  showAddKeyDialog(context,
                                    callback: (newTagName) async {
                                      if (newTagName == null || newTagName == "") {
                                        return;
                                      }
                                      var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                                      List<ContentDetail> contentDetails = <ContentDetail>[];
                                      for (var item in tagContentMap[tagName]) {
                                        contentDetails.add(ContentDetail(
                                          item.content_id,
                                          currTime,
                                          item.title,
                                          item.content,
                                          item.color,
                                          item.type,
                                          item.account,
                                          item.extra,
                                          item.tags==null?<String>[newTagName]:
                                          item.tags.where((tagItem) => tagItem != tagName).toList()..add(newTagName),
                                        ));
                                      }
                                      Navigator.of(context).pop();
                                      showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
                                      var masterPassword = await StoreUtils.getMasterPassword();
                                      for (var contentDetail in contentDetails) {
                                        var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                                        getDataModel().updateContentInfo(contentInfo);
                                      }
                                      initContentList();
                                    },
                                    keyName: AppLocalizations.of(context).getLanguageText('tag_name'),
                                    keyNameHint: AppLocalizations.of(context).getLanguageText('tag_name_input_hint'),
                                    initValue: tagName,
                                  );
                                },
                              ),
                              ActionItem(
                                icon: 'images/ic_close.png',
                                color: Colors.orange,
                                text: AppLocalizations.of(context).getLanguageText('delete_tag'),
                                onClickListener: () async {
                                  var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                                  List<ContentDetail> contentDetails = <ContentDetail>[];
                                  for (var item in tagContentMap[tagName]) {
                                    contentDetails.add(ContentDetail(
                                      item.content_id,
                                      currTime,
                                      item.title,
                                      item.content,
                                      item.color,
                                      item.type,
                                      item.account,
                                      item.extra,
                                      item.tags==null?<String>[]:item.tags.where((tagItem) => tagItem != tagName).toList(),
                                    ));
                                  }
                                  Navigator.of(context).pop();
                                  showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
                                  var masterPassword = await StoreUtils.getMasterPassword();
                                  for (var contentDetail in contentDetails) {
                                    var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                                    getDataModel().updateContentInfo(contentInfo);
                                  }
                                  initContentList();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }))..add(Container(
                  height: 70.0,
                )),
              ),
            ),
          ],
        );
        break;
      case 1:
        w = CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: new SliverChildListDelegate(
                <Widget>[]..addAll(filterContentList.where((contentDetail) {
                  if (contentDetail.title.toLowerCase().contains(_keyword.toLowerCase())) {
                    return true;
                  }
                  return false;
                }).map((item) {
                  return ContentItem(
                    contentDetail: item,
                    onClickListener: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ContentPage(
                          contentType: item.type,
                          contentID: item.content_id,
                          refreshCallback: () async {
                            initContentList();
                          },
                          tagName: tagName,
                        )),
                      );
                    },
                    onLongPressListener: () {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            contentPadding: EdgeInsets.only(),
                            children: <Widget>[
                              tagName!=null&&tagName!=""?ActionItem(
                                icon: 'images/ic_close.png',
                                color: Colors.orange,
                                text: AppLocalizations.of(context).getLanguageText('remove_from_tag'),
                                onClickListener: () async {
                                  var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                                  List<ContentDetail> contentDetails = List<ContentDetail>();
                                  contentDetails.add(ContentDetail(
                                    item.content_id,
                                    currTime,
                                    item.title,
                                    item.content,
                                    item.color,
                                    item.type,
                                    item.account,
                                    item.extra,
                                    item.tags==null?<String>[]:item.tags.where((tagItem) => tagItem != tagName).toList(),
                                  ));
                                  Navigator.of(context).pop();
                                  showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
                                  var masterPassword = await StoreUtils.getMasterPassword();
                                  for (var contentDetail in contentDetails) {
                                    var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                                    getDataModel().updateContentInfo(contentInfo);
                                  }
                                  initContentList();
                                },
                              ):Container(),
                              ActionItem(
                                icon: 'images/ic_delete.png',
                                color: Colors.red,
                                text: AppLocalizations.of(context).getLanguageText('delete'),
                                onClickListener: () async {
                                  Navigator.of(context).pop();
                                  onDeleteClick(item);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }).toList())..add(Container(
                  height: 70.0,
                )),
              ),
            ),
          ],
        );
        break;
    }
    return WillPopScope(
      onWillPop: () async {
        if (level > 0) {
          goBack();
          return false;
        }
        return true;
      },
      child: Stack(
        children: <Widget>[
          w,
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                level==1?GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF24292E),
                    ),
                    child: Icon(
                      IconFonts.arrowLeft,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                  onTap: goBack,
                ):Container(),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorUtils.getTagBgColor(),
                      border: Border.all(color: ColorUtils.getTagColor()),
                    ),
                    child: Icon(
                      IconFonts.add,
                      color: ColorUtils.white,
                      size: 25.0,
                    ),
                  ),
                  onTap: () {
                    if (contentType > 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                          ContentPage(
                            contentType: contentType,
                            refreshCallback: () async {
                              initContentList();
                            },
                            tagName: tagName,
                          ),
                        ),
                      );
                    } else {
                      showDialog<Null>(
                        context: context,
                        builder: (BuildContext context) {
                          return ModalAdd(
                            key: _modalAddGlobalKey,
                            hasTag: true,
                            refreshCallback: initContentList,
                            contentList: contentList,
                            tags: tags,
                            tagName: tagName,
                            parentContext: this.context,
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContentItem extends StatelessWidget {
  final ContentDetail contentDetail;
  final VoidCallback onClickListener;
  final VoidCallback onLongPressListener;

  ContentItem({Key key, @required this.contentDetail,
    @required this.onClickListener, @required this.onLongPressListener}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemIcon = "images/ic_tag.png";
    var itemIconColor = ColorUtils.getTagColor();
    var itemIconBgColor = ColorUtils.getTagBgColor();
    switch (contentDetail.type) {
      case PasswordType:
        itemIcon = "images/ic_key.png";
        itemIconColor = ColorUtils.getPasswordColor();
        itemIconBgColor = ColorUtils.getPasswordBgColor();
        break;
      case TextType:
        itemIcon = "images/ic_file-text.png";
        itemIconColor = ColorUtils.getTextColor();
        itemIconBgColor = ColorUtils.getTextBgColor();
        break;
      case TOTPType:
        itemIcon = "images/ic_stopwatch.png";
        itemIconColor = ColorUtils.getTotpColor();
        itemIconBgColor = ColorUtils.getTotpBgColor();
        break;
      case 5:
        itemIcon = "images/ic_all.png";
        itemIconColor = ColorUtils.getTagColor();
        itemIconBgColor = ColorUtils.getTagBgColor();
        break;
    }
    return InkWell(
      onTap: onClickListener,
      onLongPress: onLongPressListener,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5.0),
              margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: itemIconColor),
                color: itemIconBgColor,
                borderRadius: BorderRadius.all(Radius.circular(999.0))
              ),
              child: Image.asset(itemIcon, width: 16.0, height: 16.0),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 5.0, top: 13.0, bottom: 13.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ColorUtils.divider)),
                ),
                child: Text(
                  contentDetail.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: ColorUtils.textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModalAdd extends StatefulWidget {
  final bool hasTag;
  final VoidCallback refreshCallback;
  final List<ContentDetail> contentList;
  final List<String> tags;
  final String tagName;
  final BuildContext parentContext;

  ModalAdd({Key key, @required this.hasTag, @required this.refreshCallback, @required this.contentList, @required this.tags,
    @required this.tagName, @required this.parentContext}):super(key: key);

  @override
  ModalAddState createState() => ModalAddState(
    hasTag: hasTag,
    refreshCallback: refreshCallback,
    contentList: contentList,
    tags: tags,
    tagName: tagName,
    parentContext: parentContext,
  );
}

class ModalAddState extends State<ModalAdd> {
  final bool hasTag;
  final VoidCallback refreshCallback;
  final tagNameCtl = TextEditingController();
  final keywordCtl = TextEditingController();
  final List<String> tags;
  final String tagName;
  final BuildContext parentContext;

  bool isSubmit = false;
  List<ContentDetail> contentList;
  int level = 0;
  String tagNameErr = '';
  List<ContentDetail> selectedContentList = List<ContentDetail>();

  ModalAddState({@required this.hasTag, @required this.refreshCallback, @required this.contentList, @required this.tags,
    @required this.tagName, @required this.parentContext});

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var body = <Widget>[];
    switch (level) {
      case 0:
        body.addAll(<Widget>[
          (tagName==null||tagName=="")&&contentList.length>0?ModalAddItem(
            type: 0,
            text: AppLocalizations.of(context).getLanguageText('add_tag'),
            onClickListener: () {
              setState(() {
                level = 1;
              });
            },
          ):Container(),
          tagName==null||tagName==""?Container():ModalAddItem(
            type: 5,
            text: AppLocalizations.of(context).getLanguageText('add_exists_content'),
            onClickListener: () {
              setState(() {
                level = 2;
              });
            },
          ),
          ModalAddItem(
            type: PasswordType,
            text: AppLocalizations.of(context).getLanguageText('add_password'),
            onClickListener: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                  ContentPage(
                    contentType: PasswordType,
                    refreshCallback: () {
                      refreshCallback();
                    },
                    tagName: tagName,
                  ),
                ),
              );
            },
          ),
          ModalAddItem(
            type: TextType,
            text: AppLocalizations.of(context).getLanguageText('add_text'),
            onClickListener: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                  ContentPage(
                    contentType: TextType,
                    refreshCallback: () {
                      refreshCallback();
                    },
                    tagName: tagName,
                  ),
                ),
              );
            },
          ),
          ModalAddItem(
            type: TOTPType,
            text: AppLocalizations.of(context).getLanguageText('add_totp'),
            onClickListener: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                  ContentPage(
                    contentType: TOTPType,
                    refreshCallback: () {
                      refreshCallback();
                    },
                    tagName: tagName,
                  ),
                ),
              );
            },
          ),
        ]);
        break;
      case 1:
        body.addAll(<Widget>[
          Container(
            child: FormInput(
              keyName: AppLocalizations.of(context).getLanguageText('tag_name'),
              valueCtl: tagNameCtl,
              hintText: AppLocalizations.of(context).getLanguageText('tag_name_input_hint'),
              onchange: (newText) {
                setState(() {
                  tagNameErr = '';
                });
              },
              errText: tagNameErr,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10, right: 10.0, top: 10.0, bottom: 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 10.0),
                      padding: EdgeInsets.all(5.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('cancel'),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('confirm'),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (tagNameCtl.text == '') {
                        setState(() {
                          tagNameErr = AppLocalizations.of(context).getLanguageText('required');
                        });
                      } else if (tags.where((tagItem) => tagItem == tagNameCtl.text).length > 0) {
                        setState(() {
                          tagNameErr = AppLocalizations.of(context).getLanguageText('tag_name_exists');
                        });
                      } else if (selectedContentList.length <= 0) {
                        showErrorToast(AppLocalizations.of(context).getLanguageText('content_required'));
                      } else {
                        if (isSubmit) {
                          return;
                        }
                        isSubmit = true;
                        var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                        List<ContentDetail> contentDetails = <ContentDetail>[];
                        for (var contentItem in selectedContentList) {
                          contentDetails.add(ContentDetail(
                            contentItem.content_id,
                            currTime,
                            contentItem.title,
                            contentItem.content,
                            contentItem.color,
                            contentItem.type,
                            contentItem.account,
                            contentItem.extra,
                            <String>[]..addAll(contentItem.tags)..add(tagNameCtl.text),
                          ));
                        }
                        Navigator.of(context).pop();
                        showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
                        var masterPassword = await StoreUtils.getMasterPassword();
                        for (var contentDetail in contentDetails) {
                          var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                          getDataModel().updateContentInfo(contentInfo);
                        }
                        this.refreshCallback();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200]),
        ]);
        body.add(Container(
          margin: EdgeInsets.all(10.0),
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xfff2f4f8),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  controller: keywordCtl,
                  scrollPadding: EdgeInsets.all(0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      gapPadding: 0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                        style: BorderStyle.none
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      gapPadding: 0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                        style: BorderStyle.none
                      ),
                    ),
                    fillColor: Colors.transparent,
                    hintText: AppLocalizations.of(context).getLanguageText('keyword_hint'),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  onChanged: (_) {
                    setState(() {

                    });
                  },
                ),
              ),
            ],
          ),
        ));
        body.addAll(contentList.where((item) {
          if (this.keywordCtl.text == '') return true;
          if (item.title.contains(this.keywordCtl.text)) return true;
          return false;
        }).map((item) {
          return ModalAddContentItem(
            type: item.type,
            text: item.title,
            onClickListener: () {
              if (selectedContentList.where((selectedItem) => selectedItem.content_id == item.content_id).length > 0) {
                selectedContentList.removeWhere((selectedItem) => selectedItem.content_id == item.content_id);
              } else {
                selectedContentList.add(item);
              }
              setState(() {

              });
            },
            selected: selectedContentList.where((selectedItem) => selectedItem.content_id == item.content_id).length > 0,
          );
        }));
        break;
      case 2:
        body.addAll(<Widget>[
          Container(
            margin: EdgeInsets.only(left: 10, right: 10.0, top: 10.0, bottom: 0.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(right: 10.0),
                      padding: EdgeInsets.all(5.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('cancel'),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      ),
                      child: Text(
                        AppLocalizations.of(context).getLanguageText('confirm'),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (selectedContentList.length <= 0) {
                        showErrorToast(AppLocalizations.of(context).getLanguageText('content_required'));
                      } else {
                        if (isSubmit) {
                          return;
                        }
                        isSubmit = true;
                        var currTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
                        List<ContentDetail> contentDetails = <ContentDetail>[];
                        for (var contentItem in selectedContentList) {
                          contentDetails.add(ContentDetail(
                            contentItem.content_id,
                            currTime,
                            contentItem.title,
                            contentItem.content,
                            contentItem.color,
                            contentItem.type,
                            contentItem.account,
                            contentItem.extra,
                            <String>[]..addAll(contentItem.tags)..add(tagName),
                          ));
                        }
                        Navigator.of(context).pop();
                        showLoadingDialog(context, AppLocalizations.of(context).getLanguageText('processing'));
                        var masterPassword = await StoreUtils.getMasterPassword();
                        for (var contentDetail in contentDetails) {
                          var contentInfo = await convert2ContentInfo(masterPassword, contentDetail);
                          getDataModel().updateContentInfo(contentInfo);
                        }
                        this.refreshCallback();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[200]),
        ]);
        body.add(Container(
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: const Color(0xfff2f4f8),
            borderRadius: BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: TextField(
                  controller: keywordCtl,
                  scrollPadding: EdgeInsets.all(0),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      gapPadding: 0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                        style: BorderStyle.none
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                      gapPadding: 0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 0,
                        style: BorderStyle.none
                      ),
                    ),
                    fillColor: Colors.transparent,
                    hintText: AppLocalizations.of(context).getLanguageText('keyword_hint'),
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  onChanged: (_) {
                    setState(() {

                    });
                  },
                ),
              ),
            ],
          ),
        ));
        body.addAll(contentList.where((item) {
          if (item.tags.contains(tagName)) return false;
          if (this.keywordCtl.text == '') return true;
          if (item.title.contains(this.keywordCtl.text)) return true;
          return false;
        }).map((item) {
          return ModalAddContentItem(
            type: item.type,
            text: item.title,
            onClickListener: () {
              if (selectedContentList.where((selectedItem) => selectedItem.content_id == item.content_id).length > 0) {
                selectedContentList.removeWhere((selectedItem) => selectedItem.content_id == item.content_id);
              } else {
                selectedContentList.add(item);
              }
              setState(() {

              });
            },
            selected: selectedContentList.where((selectedItem) => selectedItem.content_id == item.content_id).length > 0,
          );
        }));
        break;
    }
    return SimpleDialog(
      contentPadding: EdgeInsets.only(),
      backgroundColor: ColorUtils.themeColor,
      children: body,
    );
  }
}

class ModalAddItem extends StatelessWidget {
  final int type;
  final String text;
  final VoidCallback onClickListener;

  ModalAddItem({Key key, @required this.type, @required this.text, @required this.onClickListener}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemIcon = "images/ic_tag.png";
    var itemIconColor = ColorUtils.getTagColor();
    var itemIconBgColor = ColorUtils.getTagBgColor();
    switch (this.type) {
      case PasswordType:
        itemIcon = "images/ic_key.png";
        itemIconColor = ColorUtils.getPasswordColor();
        itemIconBgColor = ColorUtils.getPasswordBgColor();
        break;
      case TextType:
        itemIcon = "images/ic_file-text.png";
        itemIconColor = ColorUtils.getTextColor();
        itemIconBgColor = ColorUtils.getTextBgColor();
        break;
      case TOTPType:
        itemIcon = "images/ic_stopwatch.png";
        itemIconColor = ColorUtils.getTotpColor();
        itemIconBgColor = ColorUtils.getTotpBgColor();
        break;
      case 5:
        itemIcon = "images/ic_all.png";
        itemIconColor = ColorUtils.getTagColor();
        itemIconBgColor = ColorUtils.getTagBgColor();
        break;
    }
    return MaterialButton(
      onPressed: onClickListener,
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: itemIconColor),
              color: itemIconBgColor,
              borderRadius: BorderRadius.all(Radius.circular(999.0))
            ),
            child: Image.asset(itemIcon, width: 16.0, height: 16.0),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 5.0, top: 16.0, bottom: 15.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                  color: ColorUtils.textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModalAddContentItem extends StatelessWidget {
  final int type;
  final String text;
  final VoidCallback onClickListener;
  final bool selected;

  ModalAddContentItem({Key key, @required this.type, @required this.text, @required this.onClickListener,
    @required this.selected}): super(key: key);

  @override
  Widget build(BuildContext context) {
    var itemIcon = "images/ic_tag.png";
    var itemIconColor = ColorUtils.getTagColor();
    switch (this.type) {
      case PasswordType:
        itemIcon = "images/ic_key.png";
        itemIconColor = ColorUtils.getPasswordColor();
        break;
      case TextType:
        itemIcon = "images/ic_file-text.png";
        itemIconColor = ColorUtils.getTextColor();
        break;
      case TOTPType:
        itemIcon = "images/ic_stopwatch.png";
        itemIconColor = ColorUtils.getTotpColor();
        break;
    }
    return MaterialButton(
      onPressed: onClickListener,
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
            child: Icon(
              selected?IconFonts.check_box_outline:IconFonts.check_box_outline_bl,
              color: Colors.black54,
              size: 20.0,
            ),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: itemIconColor,
                borderRadius: BorderRadius.all(Radius.circular(999.0))
            ),
            child: Image.asset(itemIcon, width: 16.0, height: 16.0),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 5.0, top: 16.0, bottom: 15.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200])),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xff434343),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ActionItem extends StatelessWidget {
  final String icon;
  final Color color;
  final String text;
  final VoidCallback onClickListener;

  ActionItem({Key key, @required this.icon, @required this.color, @required this.text,
    @required this.onClickListener}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onClickListener,
      padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.symmetric(horizontal: 7.0,vertical: 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(999.0))
            ),
            child: Image.asset(icon, width: 16.0, height: 16.0),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.only(left: 5.0, top: 16.0, bottom: 15.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200])),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xff434343),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}