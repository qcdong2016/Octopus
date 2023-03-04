import 'dart:async';

import 'package:dio/dio.dart';
import 'package:protobuf/protobuf.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'data.dart';

class ClientHttp extends RpcClient {
  @override
  Future<T> invoke<T extends GeneratedMessage>(
      ClientContext? ctx,
      String serviceName,
      String methodName,
      GeneratedMessage request,
      T emptyResponse) {
    var url = 'http://${Data.server}/api/${serviceName}/${methodName}';

    return _invoke(url, request, emptyResponse);
  }

  Future<T> _invoke<T extends GeneratedMessage>(
      String url, GeneratedMessage request, T emptyResponse) async {
    var resp = await http.post(Uri.parse(url),
        body: base64Encode(request.writeToBuffer()),
        headers: {
          "Content-Type": "application/plain",
        });

    if (resp.statusCode == 200) {
      var js = json.decode(resp.body);
      if (js["code"] == 1) {
        return Future.error(js["data"]);
      } else {
        var d = base64Decode(js["data"]);
        emptyResponse.mergeFromBuffer(d);
      }
    }

    return Future.value(emptyResponse);
  }
}
