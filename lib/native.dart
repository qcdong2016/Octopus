import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'data.dart';

typedef CB = Function(Uint8List);
typedef CB1 = Function(String, dynamic);

enum DownStatus {
  OK,
  Cancel,
  Downloading,
  Exist,
  Error,
}

class NativeUtil {
// 1 取消，2 失败，0 成功, 3 已经存在 4 下载中
  static Future<DownStatus> saveFileAs(Message msg) async {
    String? result = await FilePicker.platform.saveFile(
      fileName: msg.filename,
      dialogTitle: "保存文件",
      lockParentWindow: true,
    );
    if (result == null) {
      return DownStatus.Cancel;
    }

    return await saveFile(msg, File(result));
  }

  static downloadAndSeek(Message msg) async {
    var file = await getSaveFile(msg, false);

    var before = DateTime.now();
    var status = await saveFileDefault(msg);

    if (status != DownStatus.OK && status != DownStatus.Exist) {
      return;
    }

    var after = DateTime.now();

    if (after.difference(before).inMilliseconds > 2000) {
      return;
    }

    await seekFile(file.path);
  }

  static downloadAndOpen(Message msg) async {
    var status = await saveFileDefault(msg);
    if (status != DownStatus.OK && status != DownStatus.Exist) {
      return;
    }

    if (Platform.isMacOS) {
      List<String> arguments = [msg.savepath];
      Process.run(
        'open',
        arguments,
      );
    } else {
      var path = msg.savepath.replaceAll("/", "\\");
      List<String> arguments = ['/k', 'explorer.exe $path'];
      Process.run(
        'cmd',
        arguments,
      );
    }
  }

  static Future<File> getSaveFile(Message msg, bool dup) async {
    if (msg.savepath != "") {
      return File(msg.savepath);
    }

    Directory tempDir = await getApplicationDocumentsDirectory();
    var dir = "${tempDir.path}/Octopus";
    var file = File('$dir/${msg.filename}');

    var index = 1;
    while (file.existsSync()) {
      var base = path.basename(msg.filename);
      var ext = path.extension(msg.filename);
      file = File('$dir/${base + '_' + index.toString() + ext}');
      index++;
    }

    return file;
  }

  static Future<DownStatus> saveFileDefault(Message msg) async {
    File file = await getSaveFile(msg, false);
    return await saveFile(msg, file);
  }

  static Future<DownStatus> saveFile(Message msg, File saveFile) async {
    if (!saveFile.existsSync()) {
      saveFile.createSync(recursive: true);
    } else {
      return DownStatus.Exist;
    }

    if (msg.downloading) {
      return DownStatus.Downloading;
    }

    msg.downloading = true;

    var url = "http://${Data.server}/downFile?file=${msg.url}";
    Response response = await Dio().download(url, saveFile.path,
        onReceiveProgress: (received, total) {
      msg.progress = received / total;
    });

    msg.downloading = false;
    msg.savepath = saveFile.path;

    if (response.statusCode != 200) {
      return DownStatus.Error;
    }

    return DownStatus.OK;
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
}
