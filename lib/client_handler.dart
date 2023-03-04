import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/pb/comm.pb.dart';
import 'package:octopus/pb/msg.pbserver.dart';
import 'package:protobuf/protobuf.dart';

class ClientHandler extends S2CServiceBase {
  @override
  Future<Empty> login(ServerContext ctx, OnLogin request) {
    if (request.hasMsg()) {
      SmartDialog.showToast(request.msg);
    } else {
      Client.instance.autoConnect();
      Data.data.init(request);
      Data.onLogin.emit();
    }
    return Future(() => Empty());
  }
}


    // Client.instance.addHandler("chat.text", (err, data) {
    //   Message msg = Message().fromJson(data);
    //   Data.data.addMessage(msg);
    // }, false);

    // Client.instance.addHandler("chat.file", (err, data) {
    //   Message msg = Message().fromJson(data);
    //   Data.data.addMessage(msg);
    // }, false);

    // Client.instance.addHandler("friendOnline", (err, data) {
    //   Data.data.setUserOnline(User().fromJson(data));
    // }, false);

    // Client.instance.addHandler("friendOffline", (err, data) {
    //   Data.data.setUserOffline(data);
    // }, false);
