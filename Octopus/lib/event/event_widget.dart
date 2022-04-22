import 'package:flutter/material.dart';
import 'package:octopus/event/event.dart';

typedef Builder = Widget Function(BuildContext context);

class EventWidget extends StatefulWidget {
  Builder buidler;
  EventBase event;

  EventWidget({Key? key, required this.buidler, required this.event})
      : super(key: key);

  @override
  _EventWidget createState() {
    return _EventWidget();
  }
}

class _EventWidget extends State<EventWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.buidler(context);
  }

  EventBlock? _block;
  @override
  void dispose() {
    widget.event.disconnect(_block);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _block = widget.event.connect(() {
      setState(() {});
    });
  }
}
