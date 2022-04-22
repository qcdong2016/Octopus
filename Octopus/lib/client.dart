import 'dart:convert';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'websocket/websocket.dart';

typedef CB = Function(String?, dynamic);

class Client {
  Client._privateConstructor();

  static final Client instance = Client._privateConstructor();

  WebSocket? _webSocket;

  void login(String userid, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? server = prefs.getString("server");
    server ??= "ws://192.168.2.191:7457";

    _webSocket?.close();
    _webSocket = await WebSocket.connect(server + "/chat");

    _webSocket?.stream.listen(dispatch);

    doSend("login", {
      "ID": int.parse(userid),
      "Password": password,
    });
  }

  static send(String route, data, {CB? cb}) {
    instance.doSend(route, data, cb: cb);
  }

  late Timer _timer;

  void tick() {
    const timeInterval = const Duration(seconds: 1);

    _timer = Timer.periodic(timeInterval, (timer) {
      if (_webSocket != null &&
          _webSocket!.readyState == _webSocket!.state_connecting) {
        // _webSocket.ping();
      }
    });
  }

  dispatch(dynamic message) {
    var index = message.indexOf("}");
    var msg = jsonDecode(message.substring(0, index + 1));

    print(["recv", message]);
    print(msg);

    if (msg["err"] != null) {
      // msgBox.show(msg.err);
      print(msg["err"]);
    }

    var data = jsonDecode(message.substring(index + 1));

    if (msg["cbid"] != null) {
      var cb = takeCB(msg["cbid"]);
      cb!(msg.err, data);
    }

    var route = msg['route'];
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

  doSend(String route, data, {CB? cb}) {
    var pk = pack(route, data, cb: cb);
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
    pkg["argsSize"] = args.length;

    var txt = jsonEncode(pkg) + args;
    print(["send", txt]);
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
