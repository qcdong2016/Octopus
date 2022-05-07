import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'data.dart';
import 'websocket/websocket.dart';

typedef CB = Function(String?, dynamic);

class Client {
  static final Client instance = Client();

  WebSocket? _webSocket;

  Timer? _timer;

  int retryCount = 0;

  void login(String nickname, String password) async {
    Data.setUP(nickname, password);

    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_webSocket == null) {
        return;
      }

      if (_webSocket!.readyState == _webSocket!.state_open) {
        doSend("ping", {}, log: false);
      } else if (_webSocket!.readyState == _webSocket!.state_closed) {
        if (retryCount == 0) {
          SmartDialog.showLoading(
              msg: "已掉线，重连中。。", background: Colors.black.withOpacity(0.5));
        }
        retryCount++;
        _doLogin();
      }
    });
    _doLogin();
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }

  Future<void> _doLogin() async {
    _webSocket?.close();
    try {
      _webSocket = await WebSocket.connect("ws://" + Data.server + "/chat");
      _webSocket?.stream.listen(dispatch);
      doSend("login", {
        "ID": Data.data.me.nickname,
        "Password": Data.data.me.password,
      });
      if (retryCount != 0) {
        SmartDialog.dismiss();
      }
      retryCount = 0;
    } catch (e) {
      print(e);
    }
  }

  static send(String route, data, {CB? cb}) {
    instance.doSend(route, data, cb: cb);
  }

  static Future<File> downFile(
    Message msg, {
    bool saveas = false,
    bool skipWhenExist = false,
    bool skipSeek = false,
  }) async {
    Directory tempDir = await getApplicationDocumentsDirectory();
    File saveFile = File('${tempDir.path}/Octopus/${msg.filename}');

    if (saveas) {
      String? result = await FilePicker.platform.saveFile(
        fileName: msg.filename,
        dialogTitle: "保存文件",
        lockParentWindow: true,
      );
      if (result == null) {
        return saveFile;
      }
      saveFile = File(result);
    }

    if (!saveFile.existsSync()) {
      saveFile.createSync(recursive: true);
    } else if (skipWhenExist) {
      return saveFile;
    }

    if (msg.downloading) {
      return saveFile;
    }

    msg.downloading = true;

    var startTime = DateTime.now();

    var url = "http://${Data.server}/downFile?file=${msg.url}";
    Response response = await Dio().download(url, saveFile.path,
        onReceiveProgress: (received, total) {
      msg.progress = received / total;
    });

    var endTime = DateTime.now();

    msg.downloading = false;
    msg.savepath = saveFile.path;

    if (response.statusCode != 200) {
      SmartDialog.showToast('下载失败');
    } else if (!skipSeek) {
      if (endTime.difference(startTime).inMilliseconds <= 2000) {
        seekFile(saveFile.path);
      }
    }

    return saveFile;
  }

  static seekFile(String filepath) {
    if (filepath == "") {
      return;
    }
    if (Platform.isMacOS) {
      List<String> arguments = ['-R', filepath];
      Process.run(
        'open',
        arguments,
      );
    } else {
      var path = filepath.replaceAll("/", "\\");
      List<String> arguments = ['/k', 'explorer.exe /select,$path'];
      Process.run(
        'cmd',
        arguments,
      );
    }
  }

  static downloadAndOpen(Message msg) async {
    var file = await downFile(msg, skipSeek: true);

    if (Platform.isMacOS) {
      List<String> arguments = [file.path];
      Process.run(
        'open',
        arguments,
      );
    } else {
      var path = file.path.replaceAll("/", "\\");
      List<String> arguments = ['/k', 'explorer.exe $path'];
      Process.run(
        'cmd',
        arguments,
      );
    }
  }

  static _doSendFile(String type, String filename, Message msg) async {
    var url =
        "http://${Data.server}/upFile?from=${msg.from}&to=${msg.to}&type=$type";

    var pf =
        await MultipartFile.fromFile(filename, filename: basename(filename));
    var formData = FormData.fromMap({
      'file': pf,
    });

    var response =
        await Dio().post(url, data: formData, onSendProgress: (count, total) {
      msg.progress = count / total;
    });

    msg.url = response.data["URL"];
  }

  static sendFile(String type, String filename) async {
    // if (!File.fromRawPath(Uint8List.fromList(filename.codeUnits))
    //     .existsSync()) {
    //   return null;
    // }

    var from = Data.data.me.iD;
    var to = Data.data.chatTarget.iD;

    var msg = Message().fromJson({
      "Type": type,
      "From": from,
      "To": to,
      "FileName": basename(filename),
      "URL": "",
    });

    if (type == "image") {
      await _doSendFile(type, filename, msg);
    } else {
      _doSendFile(type, filename, msg);
    }

    Data.data.addMessage(msg);

    return msg;
  }

  dispatch(dynamic message) {
    var index = message.indexOf("}");
    var msg = jsonDecode(message.substring(0, index + 1));

    print(["recv", message]);

    var route = msg['route'];

    if (msg["err"] != null) {
      // msgBox.show(msg.err);
      if (route == "login") {
        disconnect();
      }
      return SmartDialog.showToast(msg["err"]);
      // print(msg["err"]);
    }

    var data = jsonDecode(message.substring(index + 1));

    if (msg["cbid"] != null) {
      var cb = takeCB(msg["cbid"]);
      cb!(msg["err"], data);
    }

    if (route != null) {
      var cbinfo = getHandler(route);
      if (cbinfo == null) {
        print(["no handler", route]);
        return;
      }

      cbinfo["func"](msg["err"], data);
      if (cbinfo["autodelete"]) {
        delHandler(route);
      }
    }
  }

  Map<String, dynamic> _handler = {};

  addHandler(String key, CB cb, bool autodelete) {
    _handler[key] = {"func": cb, "autodelete": autodelete};
  }

  delHandler(key) {
    _handler.remove(key);
  }

  getHandler(key) {
    return _handler[key];
  }

  doSend(String route, data, {CB? cb, bool? log}) {
    var pk = pack(route, data, cb: cb);
    if (log == null || log == true) {
      print(['send', pk]);
    }
    _webSocket?.add(pk);
  }

  String pack(String route, data, {CB? cb}) {
    Map<String, dynamic> pkg = {
      "route": route,
    };

    if (cb != null) {
      pkg["cbid"] = addCB(cb);
    }

    var args = jsonEncode(data);
    pkg["v"] = 2;
    pkg["argsSize"] = args.length;

    var txt = jsonEncode(pkg) + args;
    return txt;
  }

  final Map<int, CB> _cbMap = {};
  int _cbIndex = 0;

  int addCB(CB cb) {
    _cbIndex++;
    _cbMap[_cbIndex] = cb;
    return _cbIndex;
  }

  CB? takeCB(int id) {
    return _cbMap.remove(id);
  }
}
