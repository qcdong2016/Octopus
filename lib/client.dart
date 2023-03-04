import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/pb/comm.pb.dart';
import 'package:octopus/pb/msg.pb.dart';
import 'package:octopus/pb/msg.pbserver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/protobuf.dart';
import 'dart:convert';
import 'data.dart';

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

  int retryCount = 0;
  bool _isLogin = false;

  late S2CServiceBase _handler;

  void login(String nickname, String password, S2CServiceBase handler) async {
    this._handler = handler;
    Data.setUP(nickname, password);
    _connect();
  }

  void autoConnect() {
    _timer?.cancel();

    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_webSocket == null && !_isLogin) {
        return;
      }

      if (_webSocket == null ||
          _webSocket?.readyState == WebSocket.closed ||
          _webSocket?.closeCode != null) {
        if (retryCount == 0) {
          SmartDialog.showLoading(
              msg: "已掉线，重连中。。", maskColor: Colors.black.withOpacity(0.5));
        }
        retryCount++;
        _connect();
      } else if (_webSocket!.readyState == WebSocket.open) {
        doSend("ping", {});
      }
    });
  }

  void disconnect() {
    _webSocket?.close();
    _webSocket = null;
  }

  Future<void> _connect() async {
    _webSocket?.close();

    try {
      _webSocket = await WebSocket.connect(
          "ws://${Data.server}/chat?u=${Data.loginData.nickname}&p=${Data.loginData.password}");
      _webSocket?.listen(
        dispatch,
        onDone: () => _webSocket = null,
      );

      _isLogin = true;

      if (retryCount != 0) {
        SmartDialog.dismiss();
      }
      retryCount = 0;
    } catch (e) {
      print(e);
    }
  }

  static send(String route, data, {CB? cb}) {
    // instance.doSend(route, data, cb: cb);
  }

  doSend(String route, data) {}

  static _doSendFile(String type, String filename, Message msg) async {
    var url =
        "http://${Data.server}/upFile?from=${msg.from}&to=${msg.to}&type=$type";

    var pf = await MultipartFile.fromFile(filename,
        filename: path.basename(filename));
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
      "FileName": path.basename(filename),
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
