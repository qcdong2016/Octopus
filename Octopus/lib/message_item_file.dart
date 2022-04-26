import 'dart:io';

import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class FileMessageItem extends StatefulWidget {
  FileMessageItem({
    Key? key,
    required this.msg,
  }) : super(key: key);

  Message msg;

  @override
  State<FileMessageItem> createState() => _FileMessageItemState();
}

class _FileMessageItemState extends State<FileMessageItem> {
  seekFile() {
    if (widget.msg.savepath == "") {
      SmartDialog.showToast("未下载");
      return;
    }
    if (Platform.isMacOS) {
      List<String> arguments = ['-R', widget.msg.savepath];
      Process.run(
        'open',
        arguments,
      );
    } else {
      var path = widget.msg.savepath.replaceAll("/", "\\");
      List<String> arguments = ['/k', 'explorer.exe /select,$path'];
      Process.run(
        'cmd',
        arguments,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      onItemSelected: (i) {
        i.onSelected!();
      },
      menuItems: [
        MenuItem(
            title: '下载',
            onSelected: () {
              Client.downFile(widget.msg);
            }),
        MenuItem(title: '查找', onSelected: seekFile),
      ],
      child: GestureDetector(
        onTap: () {
          if (widget.msg.savepath == "") {
            Client.downFile(widget.msg);
          } else {
            seekFile();
          }
        },
        child: Container(
          height: 60,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(5, 5),
                blurRadius: 5,
                spreadRadius: 0,
              ),
            ],
          ),
          //
          child: Row(
            children: [
              SizedBox(width: 5),
              Container(
                height: 40,
                width: 40,
                color: Color.fromARGB(255, 251, 244, 176),
                child: FileIcon(
                  widget.msg.filename,
                  size: 30,
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(widget.msg.filename),
              ),
              SizedBox(width: 5),
              EventWidget(
                buidler: ((context) {
                  if (widget.msg.downloading) {
                    return CircularPercentIndicator(
                      radius: 20.0,
                      lineWidth: 5.0,
                      percent: widget.msg.progress,
                      center: Text(
                          (widget.msg.progress * 100).floor().toString() + "%"),
                      progressColor: Colors.green,
                    );
                  } else {
                    return const Icon(
                      Icons.download,
                      size: 20.0,
                    );
                  }
                }),
                event: widget.msg,
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
