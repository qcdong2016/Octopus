import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event_widget.dart';

import 'client.dart';
import 'line_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            width: 400,
            child: EventWidget(
              buidler: (context) {
                _usernameController.text = Data.data.me.nickname;
                _passwordController.text = Data.data.me.password;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // _getRoundImage('images/logo.png', 100.0),
                    const SizedBox(
                      height: 60,
                    ),
                    LineInput(
                        hint: "账号",
                        icon: Icons.mobile_friendly_rounded,
                        controller: _usernameController),
                    LineInput(
                        hint: "密码",
                        icon: Icons.lock,
                        controller: _passwordController),
                    const SizedBox(
                      height: 10,
                    ),
                    _getLoginButton(),
                  ],
                );
              },
              event: Data.data.me,
            ),
          ),
        ),
        bottomNavigationBar: Row(
          children: [
            TextButton(
              child: Text('设置'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var ctrl = TextEditingController(text: Data.server);

                      return AlertDialog(
                        content: LineInput(
                          hint: '服务器地址',
                          icon: Icons.web,
                          controller: ctrl,
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('确定'),
                            onPressed: () {
                              Data.server = ctrl.text;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
            Expanded(
              flex: 2,
              child: SizedBox.fromSize(),
            ),
            TextButton(
              child: Text('注册'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      var nickctrl = TextEditingController();
                      var passctrl = TextEditingController();

                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LineInput(
                              hint: '昵称',
                              icon: Icons.people,
                              controller: nickctrl,
                            ),
                            LineInput(
                              hint: '密码',
                              icon: Icons.lock,
                              controller: passctrl,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('确定'),
                            onPressed: () async {
                              print('http://${Data.server}/regist');
                              var resp = await Dio()
                                  .post('http://${Data.server}/regist', data: {
                                'Nickname': nickctrl.text,
                                'Password': passctrl.text,
                              });

                              Data.setUP(nickctrl.text, passctrl.text);

                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
        ));
  }

  Widget _getRoundImage(String imageName, double size) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      ),
      child: Image.asset(
        imageName,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _getLoginButton() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
        ),
        child: const Text('登录'),
        onPressed: () {
          Client.instance.login(
              _usernameController.text.trim(), _passwordController.text.trim());
          Client.instance.addHandler("login", (err, data) {
            Data.data.fromJson(data);
            Navigator.of(context).pushNamed("/chat");
          }, true);
        },
      ),
    );
  }
}
