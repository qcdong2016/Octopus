import 'package:file_icon/file_icon.dart';
import 'package:flutter/material.dart';
import 'package:octopus/data.dart';

class FileMessageItem extends StatefulWidget {
  FileMessageItem({
    Key? key,
    required this.msg,
    required this.alignment,
  })  : margin = EdgeInsets.only(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
        ),
        super(key: key);

  EdgeInsets margin;
  Message msg;
  AlignmentGeometry alignment;

  @override
  State<FileMessageItem> createState() => _FileMessageItemState();
}

class _FileMessageItemState extends State<FileMessageItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.alignment,
      margin: EdgeInsets.only(top: 10),
      child: Container(
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
        child: Row(
          children: [
            SizedBox(width: 5),
            Container(
              height: 40,
              width: 40,
              color: Color.fromARGB(255, 177, 251, 226),
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
            Icon(
              Icons.download,
              size: 20.0,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
