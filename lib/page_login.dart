import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:octopus/client_handler.dart';
import 'package:octopus/client_http.dart';
import 'package:octopus/data.dart';
import 'package:octopus/event/event.dart';
import 'package:octopus/event/event_widget.dart';
import 'package:octopus/pb/http.pb.dart';

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

  EventBlock? _block;

  @override
  void initState() {
    Data.init(() {
      _usernameController.text = Data.loginData.nickname;
      _passwordController.text = Data.loginData.password;
    });
    _block = Data.onLogin.connect(() {
      Data.setUP(_usernameController.text, _passwordController.text);
      Navigator.of(context).pushNamed("/chat");
    });
    super.initState();
  }

  @override
  void dispose() {
    Data.onLogin.disconnect(_block);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Container(
            width: 400,
            child: EventWidget(
              buidler: (context) {
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
              child: const Text('设置'),
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
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('确定'),
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
              child: const Text('注册'),
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
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('确定'),
                            onPressed: () async {
                              try {
                                await PublicApi(ClientHttp()).regist(
                                    null,
                                    RegistReq(
                                        nickname: nickctrl.text,
                                        password: passctrl.text));
                                Data.setUP(nickctrl.text, passctrl.text);
                                Navigator.of(context).pop();
                              } catch (err) {
                                SmartDialog.showToast(err.toString());
                              }
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
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Builder(
          builder: (context) {
            return TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
              ),
              child: const Text('登录'),
              onPressed: () {
                Client.instance.login(_usernameController.text.trim(),
                    _passwordController.text.trim(), ClientHandler());
              },
            );
          },
        ));
  }
}
