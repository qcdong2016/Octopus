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
      Data.data.init(request);
      if (!request.reconnect) {
        Client.instance.autoConnect();
        Data.onLogin.emit();
      }
    }
    return Future(() => Empty());
  }

  @override
  Future<Empty> onMsg(ServerContext ctx, Msg request) {
    Data.data.addMessage(request);
    return Future(() => Empty());
  }

  @override
  Future<Empty> kick(ServerContext ctx, KickReq request) {
    SmartDialog.showToast(request.msg);
    Client.instance.disconnect();
    Data.onLogout.emit();
    return Future(() => Empty());
  }

  @override
  Future<Empty> offline(ServerContext ctx, OfflineReq request) {
    Data.data.setUserOffline(request.iD.toInt());
    return Future(() => Empty());
  }

  @override
  Future<Empty> online(ServerContext ctx, OnlineReq request) {
    Data.data.setUserOnline(request.who);
    return Future(() => Empty());
  }

  @override
  Future<Empty> onUpload(ServerContext ctx, OnUploadReq request) {
    Data.data.setMsgSended(request);
    return Future(() => Empty());
  }
}
