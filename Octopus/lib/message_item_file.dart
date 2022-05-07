import 'dart:io';

import 'package:desktop_context_menu/desktop_context_menu.dart';
import 'package:file_icon/file_icon.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
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
    Client.seekFile(widget.msg.savepath);
  }

  @override
  Widget build(BuildContext context) {
    bool shouldReact = false;

    return Listener(
      onPointerDown: (e) {
        shouldReact = e.kind == PointerDeviceKind.mouse &&
            e.buttons == kSecondaryMouseButton;
      },
      onPointerUp: (PointerUpEvent e) async {
        if (shouldReact) {
          await showContextMenu(menuItems: [
            ContextMenuItem(
              title: '下载',
              onTap: () {
                Client.saveFileDefault(widget.msg);
              },
            ),
            ContextMenuItem(
              title: '查找',
              onTap: seekFile,
            ),
          ]);
        } else {
          if (widget.msg.savepath == "" ||
              !File(widget.msg.savepath).existsSync()) {
            Client.downloadAndSeek(widget.msg);
          } else {
            seekFile();
          }
        }
        shouldReact = false;
      },
      child: createFile(),
    );
  }

  Widget createFile() {
    return Container(
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
    );
  }
}
