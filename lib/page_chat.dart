import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/avatar.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/friend_list.dart';
import 'package:octopus/wx_expression.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popover/popover.dart';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_input.dart';
import 'line_input.dart';
import 'message_list.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

EventBlock? _block;

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();

    _block = Data.onLogout.connect(() {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Data.onLogout.disconnect(_block);
  }

  void showConfig() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          var nickctrl = TextEditingController(text: Data.data.me.nickname);
          Color pickerColor = Color(0xff443a49);
          Color currentColor = Color(0xff443a49);

          return AlertDialog(
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Center(
                    child: Text("我的资料"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Avatar(user: Data.data.me),
                  LineInput(
                    hint: '昵称',
                    icon: Icons.people,
                    controller: nickctrl,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('取消'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  List<Expression> favList = [];
  OverlayEntry? _overlay = null;

  Timer? _timer = null;
  bool _isOnButton = false;
  bool _isOnOverlay = false;

  hideFavFace() {
    _overlay?.remove();
    _overlay = null;
    _timer?.cancel();
    _timer = null;
  }

  leaveButton() {
    _isOnButton = false;
  }

  leaveOverlay() {
    _isOnOverlay = false;
  }

  loadFavList() async {
    if (favList.length != 0) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("favList");
    if (list == null) {
      return;
    }

    ExpressionData.init();

    for (var name in list) {
      var e = ExpressionData.expressionKV[name];
      if (e != null) {
        favList.add(e);
      }
    }
  }

  addToFav(ChatInput input, e) async {
    await this.loadFavList();

    favList.remove(e);

    favList.insert(0, e);
    if (favList.length > 16) {
      favList = favList.sublist(0, 16);
    }

    List<String> list = [];
    for (var e in favList) {
      list.add(e.name);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList("favList", list);

    input.controller.value = TextEditingValue(
        text: input.controller.text + "[${e.name}]",
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: input.controller.text.length)));
  }

  requireFocus(ChatInput input) {
    input.focusNode.requestFocus();
    input.controller.value = TextEditingValue(
        text: input.controller.text,
        selection: TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: input.controller.text.length)));
  }

  showFavFace(context1, ChatInput input) async {
    if (_overlay != null) {
      return;
    }
    await this.loadFavList();
    if (this.favList.length == 0) {
      return;
    }

    RenderBox renderBox = context1.findRenderObject();
    var parentSize = renderBox.size;
    var parentPosition = renderBox.localToGlobal(Offset.zero);
    double width = 136;
    double height = 144;

    _isOnButton = true;

    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      // print(["check", _isOnButton, _isOnOverlay]);

      if (!_isOnButton && !_isOnOverlay) {
        this.hideFavFace();
        this.requireFocus(input);
      }
    });

    _overlay = OverlayEntry(builder: (context) {
      return Positioned(
          top: parentPosition.dy - height + 6,
          left: parentPosition.dx - width / 2 + parentSize.width / 2,
          child: MouseRegion(
              onEnter: (event) {
                _isOnOverlay = true;
              },
              onExit: (event) {
                _isOnOverlay = false;
              },
              child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(
                        width: 1, color: Color.fromARGB(155, 98, 98, 98)),
                  ),
                  child: WeChatExpression(
                    (e) {
                      addToFav(input, e);
                    },
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    displayList: favList,
                    crossAxisCount: 4,
                  ))));
    });
    Overlay.of(context1).insert(_overlay!);
  }

  showFace(context1, ChatInput input) {
    showPopover(
      context: context1,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 100),
      onPop: (() => requireFocus(input)),
      bodyBuilder: (context) => WeChatExpression(
        (e) {
          addToFav(input, e);
        },
        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        displayList: ExpressionData.expressionPath,
        crossAxisCount: 12,
      ),
      direction: PopoverDirection.bottom,
      width: 500,
      height: 300,
      arrowHeight: 15,
      arrowWidth: 30,
      shadow: [
        BoxShadow(
          color: Colors.black.withAlpha(85),
          offset: const Offset(0, 8),
          blurRadius: 15,
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget createRight() {
    if (Data.data.chatTarget.iD == 0) {
      return const Center(
        child: Text("Octopus"),
      );
    }

    var input = ChatInput();
    return Column(
      children: [
        Container(
          height: 30,
          color: Color.fromARGB(255, 243, 243, 243),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                EventWidget(
                    buidler: ((context) => Text(
                          Data.data.chatTarget.nickname +
                              (Data.data.chatTarget.online ? "[在线]" : "[离线]"),
                        )),
                    event: Data.data.chatTarget),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 20,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      icon: Icon(Icons.settings),
                      onPressed: () {
                        showConfig();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: MessageList(),
        ),
        Container(
          height: 1,
          color: Colors.grey,
        ),
        Container(
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Builder(
                builder: (context1) {
                  return MouseRegion(
                      onEnter: (event) {
                        this.showFavFace(context1, input);
                      },
                      onExit: ((event) {
                        this.leaveButton();
                      }),
                      child: IconButton(
                        icon: const Icon(Icons.tag_faces),
                        iconSize: 30,
                        color: Colors.grey,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        onPressed: () {
                          this.showFace(context1, input);
                        },
                      ));
                },
              ),
              IconButton(
                icon: const Icon(Icons.cut),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  Directory tempDir = await getApplicationDocumentsDirectory();
                  var date = DateFormat("yyyy-MM-dd_HHmmss", 'en_US')
                      .format(DateTime.now());

                  File file =
                      File('${tempDir.path}/Octopus/ScreenShot/SC_$date.jpg');
                  file.createSync(recursive: true);

                  CapturedData? capturedData =
                      await ScreenCapturer.instance.capture(
                    mode: CaptureMode.region, // screen, window
                    imagePath: file.path,
                  );

                  if (capturedData == null) {
                    SmartDialog.showToast("错误");
                  } else {
                    Client.sendFile(file.path, true);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.crop_original),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png', 'gif'],
                  );
                  if (result != null && result.files.single.path != null) {
                    Client.sendFile(result.files.single.path!, true);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.folder_open),
                iconSize: 30,
                color: Colors.grey,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    Client.sendFile(result.files.single.path!, false);
                  }
                },
              ),
            ],
          ),
        ),
        Container(
          height: 150,
          child: input,
        )
        // ,
        // MessageList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 150,
            child: EventWidget(
              buidler: (context) => FriendList(),
              event: MultiEvent(
                  list: [Data.data.friendListEvent, Data.data.chatTargetEvent]),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey,
          ),
          Expanded(
            child: EventWidget(
              buidler: (context) => createRight(),
              event: Data.data.chatTargetEvent,
            ),
          ),
        ],
      ),
    );
  }
}
