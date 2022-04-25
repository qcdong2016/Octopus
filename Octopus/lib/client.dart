import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path/path.dart';

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

  static downFile(Message msg) async {
    String? result = await FilePicker.platform.saveFile(
      fileName: msg.filename,
      dialogTitle: "保存文件",
      lockParentWindow: true,
    );

    if (result == null) {
      return;
    }

    if (msg.downloading) {
      return;
    }

    msg.downloading = true;

    var url = "http://${Data.server}/downFile?file=${msg.url}";
    Response response =
        await Dio().download(url, result, onReceiveProgress: (received, total) {
      msg.progress = received / total;
    });

    msg.downloading = false;

    if (response.statusCode != 200) {
      SmartDialog.showToast('下载失败');
    } else {
      print("成功");
    }
  }

  static _doSendFile(String type, String filename, Message msg) async {
    var url =
        "http://${Data.server}/upFile?from=${msg.from}&to=${msg.to}&type={$type}";

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
    if (!File.fromUri(Uri.parse(filename)).existsSync()) {
      return null;
    }

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
