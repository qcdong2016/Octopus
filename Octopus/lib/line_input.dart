import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LineInput extends StatefulWidget {
  String _hint = '';
  IconData? _icon;
  TextInputType _inputType = TextInputType.text;

  TextEditingController _controller = TextEditingController();

  LineInput({
    Key? key,
    required String hint,
    required IconData icon,
    TextInputType? inputType,
    TextEditingController? controller,
  }) : super(key: key) {
    _hint = hint;
    _icon = icon;
    if (inputType != null) _inputType = inputType;
    if (controller != null) _controller = controller;
  }

  get text => _controller.text;

  @override
  State<StatefulWidget> createState() {
    return _LineInput();
  }
}

class _LineInput extends State<LineInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.all(10.0),
      child: Column(
        children: [
          TextField(
            keyboardType: widget._inputType,
            obscureText: false,
            controller: widget._controller,
            decoration: InputDecoration(
              hintText: widget._hint,
              icon: Icon(
                widget._icon,
                size: 20.0,
              ),
              border: InputBorder.none,
              suffixIcon: GestureDetector(
                child: Offstage(
                  child: Icon(Icons.clear),
                  offstage: widget._controller.text == "",
                ),
                onTap: () {
                  setState(() {
                    widget._controller.clear();
                  });
                },
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          Divider(
            height: 1.0,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
