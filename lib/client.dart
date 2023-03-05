import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/pb/comm.pb.dart';
import 'package:octopus/pb/msg.pb.dart';
import 'package:octopus/pb/msg.pbserver.dart';
import 'package:path/path.dart' as path;
import 'package:protobuf/protobuf.dart';
import 'data.dart';

import 'package:fixnum/fixnum.dart' as fixnum;

typedef CB = Function(String, dynamic);

class RequestHold {
  RequestHold({required this.cb, required this.msg});
  CB cb;
  GeneratedMessage msg;
}

class Client extends RpcClient {
  static final Client instance = Client();

  WebSocket? _webSocket;

  Timer? _timer;

  late S2CServiceBase _handler;

  void login(String nickname, String password, S2CServiceBase handler) async {
    _handler = handler;
    Data.setUP(nickname, password);
    _connect("正在登录", false, nickname, password);
  }

  void autoConnect() {
    _timer?.cancel();
    _timer = null;

    _timer ??= Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_webSocket == null ||
          _webSocket?.readyState == WebSocket.closed ||
          _webSocket?.closeCode != null) {
        _connect("已掉线，重连中。。", true, Data.loginData.nickname,
            Data.loginData.password);
      } else if (_webSocket!.readyState == WebSocket.open) {
        ping();
      }
    });
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _connect(
      String msg, bool reconnect, String nickname, String password) async {
    SmartDialog.showLoading(msg: msg, maskColor: Colors.black.withOpacity(0.5));

    _webSocket?.close();

    try {
      _webSocket = await WebSocket.connect(
          "ws://${Data.server}/chat?u=$nickname&p=$password&r=$reconnect");
      _webSocket?.listen(
        dispatch,
        onDone: () => _webSocket = null,
      );

      SmartDialog.dismiss();
    } catch (e) {
      if (!reconnect) {
        SmartDialog.dismiss();
      }

      if (reconnect) {
        print(e.toString());
        return;
      }
      if (e is SocketException) {
        SmartDialog.showToast(e.message);
      } else {
        SmartDialog.showToast(e.toString());
      }
    }
  }

  static _doSendFile(Message msg, String filename) async {
    var url = "http://${Data.server}/upFile?id=${msg.id}";

    var pf = await MultipartFile.fromFile(filename,
        filename: path.basename(filename));
    var formData = FormData.fromMap({
      'file': pf,
    });
  }

  static _sendFile(Msg one, String filename) async {
    var resp = await ChatApi(Client.instance).send(null, one);
    var msg = Data.data.addMessage(resp);
    await _doSendFile(msg, filename);
    msg.sended = true;
    Data.data.animateScroller(Data.data.pageScrollerController);
  }

  static sendMsg(int to, what) async {
    var msg = Msg(
      to: fixnum.Int64(to),
    );
    if (what is TextMsg) {
      msg.text = what;
    } else if (what is FocusMsg) {
      msg.focus = what;
    }
    var resp = await ChatApi(Client.instance).send(null, msg);
    Data.data.addMessage(resp);
  }

  static sendFile(String filename, bool isImage) {
    var msg = Msg(
      to: fixnum.Int64(Data.data.chatTarget.iD),
    );
    if (isImage) {
      msg.image = ImageMsg(fileName: path.basename(filename));
    } else {
      msg.file = FileMsg(fileName: path.basename(filename));
    }

    _sendFile(msg, filename);
  }

  dispatch(dynamic message) {
    var data = S2CData.fromBuffer(message);

    if (data.hasCallback()) {
      var cb = takeCB(data.callback.toInt());
      if (cb != null) {
        cb.msg.mergeFromBuffer(data.body);
        cb.cb(data.error, cb.msg);
        print(["Recv", data.callback, cb.msg.toProto3Json()]);
      } else {
        print("callback not found.");
      }
    } else {
      var req = _handler.createRequest(data.method);
      req.mergeFromBuffer(data.body);

      print(["Recv", data.method, req.toProto3Json()]);

      _handler.handleCall(ServerContext(), data.method, req);
    }
  }

  final Map<int, RequestHold> _cbMap = {};
  int _cbIndex = 0;

  int addCB(RequestHold cb) {
    _cbIndex++;
    _cbMap[_cbIndex] = cb;
    return _cbIndex;
  }

  RequestHold? takeCB(int id) {
    return _cbMap.remove(id);
  }

  ping() async {
    await ChatApi(this).ping(null, Empty());
  }

  @override
  Future<T> invoke<T extends GeneratedMessage>(
      ClientContext? ctx,
      String serviceName,
      String methodName,
      GeneratedMessage request,
      T emptyResponse) {
    final com = Completer<T>();

    cb(err, data) {
      if (err != "") {
        com.completeError(err);
      } else {
        com.complete(data);
      }
    }

    C2SData pkg = C2SData(
        method: serviceName + "/" + methodName, body: request.writeToBuffer());

    pkg.callback = Int64(addCB(RequestHold(cb: cb, msg: emptyResponse)));

    _webSocket?.add(pkg.writeToBuffer());

    return com.future;
  }
}
