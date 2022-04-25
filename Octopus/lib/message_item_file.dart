import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:octopus/client.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 200,
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
      child: GestureDetector(
        onTap: () {
          Client.downFile(widget.msg);
        },
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
    );
  }
}
