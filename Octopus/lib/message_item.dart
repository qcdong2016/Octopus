import 'package:bubble/bubble.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    Key? key,
    required this.isLeft,
    required this.content,
  }) : super(key: key);

  bool isLeft = false;
  String content = "";

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Colors.white,
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );

  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color.fromARGB(255, 225, 255, 199),
    borderColor: Colors.blue,
    borderWidth: 1,
    elevation: 4,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );

  static const textStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.normal,
  );

  static const selfBubbleColor = Color.fromARGB(255, 183, 232, 250);
  static const otherBubbleColor = Color.fromARGB(255, 188, 250, 236);

  Widget _createLeft({required String msg}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topLeft,
      nip: BubbleNip.leftTop,
      color: otherBubbleColor,
      child: getRichText(msg),
    );
  }

  Widget _createRight({required String msg}) {
    return Bubble(
      margin: BubbleEdges.only(top: 10),
      alignment: Alignment.topRight,
      nip: BubbleNip.rightTop,
      color: selfBubbleColor,
      child: getRichText(msg),
    );
  }

// Bubble(
//             alignment: Alignment.center,
//             color: Color.fromARGB(255, 237, 249, 255),
//             child: Text('TODAY', textAlign: TextAlign.center, style: textStyle),
//           ),
  @override
  Widget build(BuildContext context) {
    if (widget.isLeft)
      return _createLeft(msg: widget.content);
    else
      return _createRight(msg: widget.content);
  }

  //图文混排
  static getRichText(String text) {
    List<InlineSpan> textSapns = [];

    String urlExpString =
        r"(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?";
    String emojExpString = r"\[.{1,4}?\]";
    RegExp exp = RegExp('$urlExpString|$emojExpString');

    //正则表达式是否在字符串[input]中有匹配。
    if (exp.hasMatch(text)) {
      Iterable<RegExpMatch> matches = exp.allMatches(text);

      int index = 0;
      int count = 0;
      for (var matche in matches) {
        count++;
        String c = text.substring(matche.start, matche.end);
        //匹配到的东西,如表情在首位
        if (index == matche.start) {
          index = matche.end;
        }
        //匹配到的东西,如表情不在首位
        else if (index < matche.start) {
          String leftStr = text.substring(index, matche.start);
          index = matche.end;
          textSapns.add(TextSpan(
              text: spaceWord(leftStr),
              style: const TextStyle(color: Colors.black, fontSize: 17)));
        }

        //匹配到的网址
        if (RegExp(urlExpString).hasMatch(c)) {
          textSapns.add(TextSpan(
              text: spaceWord(c),
              style: const TextStyle(color: Colors.red, fontSize: 17),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  await launch(c);
                  //打开浏览器
                  print(c);
                }));
        }
        //匹配到的表情
        else if (RegExp(emojExpString).hasMatch(c)) {
          //[偷笑] 去掉[] = 偷笑
          String emojiString = c.substring(1, c.length - 1);
          textSapns.add(WidgetSpan(
              style: const TextStyle(height: 1.5),
              //判断表情是否存在
              child: emojis.contains(emojiString)
                  ? Image.asset(
                      "lib/expression/$emojiString.png",
                      width: 22,
                      height: 22,
                    )
                  : Text(c,
                      style:
                          const TextStyle(color: Colors.black, fontSize: 17))));
        }

        //是否是最后一个表情,并且后面是否有字符串
        if (matches.length == count && text.length > index) {
          String rightStr = text.substring(index, text.length);
          textSapns.add(TextSpan(
              text: spaceWord(rightStr),
              style: const TextStyle(color: Colors.black, fontSize: 17)));
        }
      }
    } else {
      textSapns.add(TextSpan(
          text: spaceWord(text),
          style: const TextStyle(color: Colors.black, fontSize: 17)));
    }
    return SelectableText.rich(TextSpan(children: textSapns));
    // return Text.rich(TextSpan(children: textSapns)
  }

  static String spaceWord(String text) {
    if (text.isEmpty) return text;
    String spaceWord = '';
    for (var element in text.runes) {
      spaceWord += String.fromCharCode(element);
      spaceWord += '\u200B';
    }
    return spaceWord;
  }

  static final List emojis = [
    "爱心",
    "傲慢",
    "白眼",
    "抱拳",
    "鄙视",
    "闭嘴",
    "便便",
    "擦汗",
    "菜刀",
    "吃瓜",
    "呲牙",
    "打脸",
    "大哭",
    "蛋糕",
    "得意",
    "凋谢",
    "调皮",
    "发",
    "发呆",
    "发抖",
    "发怒",
    "奋斗",
    "福",
    "尴尬",
    "勾引",
    "鼓掌",
    "哈欠",
    "害羞",
    "憨笑",
    "汗",
    "好的",
    "呵呵",
    "嘿哈",
    "红包",
    "坏笑",
    "机智",
    "鸡",
    "加油",
    "加油加油",
    "奸笑",
    "惊恐",
    "惊讶",
    "囧",
    "咖啡",
    "可怜",
    "抠鼻",
    "骷髅",
    "快哭了",
    "困",
    "蜡烛",
    "礼物",
    "流汗",
    "流泪",
    "玫瑰",
    "难过",
    "怄火",
    "啤酒",
    "撇嘴",
    "强",
    "敲打",
    "亲亲",
    "拳头",
    "弱",
    "色",
    "社会社会",
    "衰",
    "睡",
    "太阳",
    "天哪",
    "跳跳",
    "偷笑",
    "吐",
    "哇",
    "旺柴",
    "委屈",
    "握手",
    "捂脸",
    "西瓜",
    "心碎",
    "嘘",
    "耶",
    "疑问",
    "阴险",
    "拥抱",
    "悠闲",
    "右哼哼",
    "愉快",
    "月亮",
    "晕",
    "再见",
    "炸弹",
    "咒骂",
    "皱眉",
    "猪头",
    "抓狂",
    "转圈圈",
    "嘴唇",
    "左哼哼",
    "胜利",
  ];
}
