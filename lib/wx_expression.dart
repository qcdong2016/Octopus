import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//╔══════════════════════════╗
//║ Author       : 贾恒飞
//║ Timer        : 2020/3/6
//║ Model        : yunim
//║ PackageName  : com.tencent.mm
//║ Node         : 微信表情
//╚══════════════════════════╝

///表情组件
class WeChatExpression extends StatelessWidget {
  ///一行表情数量
  final int crossAxisCount;

  final CallClick _callClick;
  late List<Expression> displayList;
  final EdgeInsetsGeometry padding;

  WeChatExpression(this._callClick,
      { 
        required this.crossAxisCount, 
      required this.displayList,
      required this.padding,
      });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 2, 0, 2),
          child: GridView.custom(
            // padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            padding:this.padding, //EdgeInsets.fromLTRB(10, 4, 10, 4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
            ),
            childrenDelegate: SliverChildBuilderDelegate((context, position) {
              return AExpression(displayList[position], _callClick);
            }, childCount: displayList.length),
          ),
        ));
  }
}

///单个表情
class AExpression extends StatelessWidget {
  Expression expression;

  final CallClick _callClick;

  AExpression(this.expression, this._callClick);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(2))),
      child: SizedBox(
        child: Image(
          image: expression.asset,
        ),
        width: 35,
        height: 35,
      ),
      onPressed: () {
        _callClick(expression);
      },
    );
  }
}

///点击之后
typedef void CallClick(Expression expression);

///表情对象
class Expression {
  static String basePath = "assets/qq/";

  final String name;
  final String path;
  AssetImage asset;

  ///标识是否是emoji表情,true是,默认false
  final bool isEmoji;

  Expression(this.name, this.path, {this.isEmoji = false})
      : asset = AssetImage(basePath + path);
}

///数据类
class ExpressionData {
  ///基础路径
  static final List<Expression> old = [
    Expression('微笑', 'hehe.png'),
    Expression('撇嘴', 'piezui.png'),
    Expression('色', 'se.png'),
    Expression('发呆', 'fadai.png'),
    Expression('得意', 'deyi.png'),
    Expression('流泪', 'liulei.png'),
    Expression('害羞', 'haixiu.png'),
    Expression('闭嘴', 'bizui.png'),
    Expression('睡', 'shui.png'),
    Expression('大哭', 'daku.png'),
    Expression('尴尬', 'ganga.png'),
    Expression('发怒', 'fanu.png'),
    Expression('调皮', 'tiaopi.png'),
    Expression('呲牙', 'ciya.png'),
    Expression('惊讶', 'jingya.png'),
    Expression('难过', 'nanguo.png'),
    Expression('囧', 'jiong.png'),
    Expression('抓狂', 'zhuakuang.png'),
    Expression('吐', 'tu.png'),
    Expression('偷笑', 'touxiao.png'),
    Expression('愉快', 'yukuai.png'),
    Expression('白眼', 'baiyan.png'),
    Expression('傲慢', 'aoman.png'),
    Expression('困', 'kun.png'),
    Expression('惊恐', 'jingkong.png'),
    Expression('流汗', 'liuhan.png'),
    Expression('憨笑', 'hanxiao.png'),
    Expression('悠闲', 'youxian.png'),
    Expression('奋斗', 'fendou.png'),
    Expression('咒骂', 'zhouma.png'),
    Expression('疑问', 'yiwen.png'),
    Expression('嘘', 'xu.png'),
    Expression('晕', 'yun.png'),
    Expression('衰', 'sui.png'),
    Expression('骷髅', 'kulou.png'),
    Expression('敲打', 'qiaoda.png'),
    Expression('再见', 'zaininmadejian.png'),
    Expression('擦汗', 'cahan.png'),
    Expression('抠鼻', 'koubi.png'),
    Expression('鼓掌', 'guzhang.png'),
    Expression('坏笑', 'huaixiao.png'),
    Expression('左哼哼', 'zuohengheng.png'),
    Expression('右哼哼', 'youhengheng.png'),
    Expression('哈欠', 'haqian.png'),
    Expression('鄙视', 'bishi.png'),
    Expression('委屈', 'weiqu.png'),
    Expression('快哭了', 'kuaikule.png'),
    Expression('阴险', 'yinxian.png'),
    Expression('亲亲', 'qinqin.png'),
    Expression('可怜', 'kelian.png'),
    Expression('菜刀', 'caidao.png'),
    Expression('西瓜', 'xigua.png'),
    Expression('啤酒', 'pijiu.png'),
    Expression('咖啡', 'kafei.png'),
    Expression('猪头', 'zhutou.png'),
    Expression('玫瑰', 'meigui.png'),
    Expression('凋谢', 'diaoxie.png'),
    Expression('嘴唇', 'zuichun.png'),
    Expression('爱心', 'aixin.png'),
    Expression('心碎', 'xinsui.png'),
    Expression('蛋糕', 'dangao.png'),
    Expression('炸弹', 'zhadan.png'),
    Expression('便便', 'bianbian.png'),
    Expression('月亮', 'yueliang.png'),
    Expression('太阳', 'taiyang.png'),
    Expression('拥抱', 'yongbao.png'),
    Expression('强', 'qiang.png'),
    Expression('弱', 'ruo.png'),
    Expression('握手', 'woshou.png'),
    Expression('胜利', 'shengli.png'),
    Expression('抱拳', 'baoquan.png'),
    Expression('勾引', 'gouyin.png'),
    Expression('拳头', 'quantou.png'),
    Expression('OK', 'ok.png'),
    Expression('跳跳', 'tiaotiao.png'),
    Expression('发抖', 'fadou.png'),
    Expression('怄火', 'ohuo.png'),
    Expression('转圈', 'zhuanquan.png'),
    Expression('嘿哈', 'heiha.png'),
    Expression('捂脸', 'wulian.png'),
    Expression('奸笑', 'jianxiao.png'),
    Expression('机智', 'jizhi.png'),
    Expression('皱眉', 'zhoumei.png'),
    Expression('耶', 'ye.png'),
    Expression('蜡烛', 'lazhu.png'),
    Expression('红包', 'hongbao.png'),
    Expression('吃瓜', 'chigua.png'),
    Expression('加油', 'jiayou.png'),
    Expression('汗', 'han.png'),
    Expression('天啊', 'tiana.png'),
    Expression('Emm', 'emm.png'),
    Expression('社会社会', 'shehuishehui.png'),
    Expression('旺柴', 'wangchai.png'),
    Expression('好的', 'haode.png'),
    Expression('打脸', 'dalian.png'),
    Expression('加油加油', 'jiayoujiayou.png'),
    Expression('哇', 'wa.png'),
    Expression('發', 'fa.png'),
    Expression('福', 'fu.png'),
    Expression('鸡', 'ji.png'),
  ];

  ///表情路径
  static final List<Expression> expressionPath = [
    Expression('0', '0@2x.gif'),
    Expression('1', '1@2x.gif'),
    Expression('2', '2@2x.gif'),
    Expression('3', '3@2x.gif'),
    Expression('4', '4@2x.gif'),
    Expression('5', '5@2x.gif'),
    Expression('6', '6@2x.gif'),
    Expression('7', '7@2x.gif'),
    Expression('8', '8@2x.gif'),
    Expression('9', '9@2x.gif'),
    Expression('10', '10@2x.gif'),
    Expression('11', '11@2x.gif'),
    Expression('12', '12@2x.gif'),
    Expression('13', '13@2x.gif'),
    Expression('14', '14@2x.gif'),
    Expression('15', '15@2x.gif'),
    Expression('16', '16@2x.gif'),
    Expression('17', '17@2x.gif'),
    Expression('18', '18@2x.gif'),
    Expression('19', '19@2x.gif'),
    Expression('20', '20@2x.gif'),
    Expression('21', '21@2x.gif'),
    Expression('22', '22@2x.gif'),
    Expression('23', '23@2x.gif'),
    Expression('24', '24@2x.gif'),
    Expression('25', '25@2x.gif'),
    Expression('26', '26@2x.gif'),
    Expression('27', '27@2x.gif'),
    Expression('28', '28@2x.gif'),
    Expression('29', '29@2x.gif'),
    Expression('30', '30@2x.gif'),
    Expression('31', '31@2x.gif'),
    Expression('32', '32@2x.gif'),
    Expression('33', '33@2x.gif'),
    Expression('34', '34@2x.gif'),
    Expression('35', '35@2x.gif'),
    Expression('36', '36@2x.gif'),
    Expression('37', '37@2x.gif'),
    Expression('38', '38@2x.gif'),
    Expression('39', '39@2x.gif'),
    Expression('40', '40@2x.gif'),
    Expression('41', '41@2x.gif'),
    Expression('42', '42@2x.gif'),
    Expression('43', '43@2x.gif'),
    Expression('44', '44@2x.gif'),
    Expression('45', '45@2x.gif'),
    Expression('46', '46@2x.gif'),
    Expression('47', '47@2x.gif'),
    Expression('48', '48@2x.gif'),
    Expression('49', '49@2x.gif'),
    Expression('50', '50@2x.gif'),
    Expression('53', '53@2x.gif'),
    Expression('54', '54@2x.gif'),
    Expression('55', '55@2x.gif'),
    Expression('56', '56@2x.gif'),
    Expression('57', '57@2x.gif'),
    Expression('59', '59@2x.gif'),
    Expression('60', '60@2x.gif'),
    Expression('61', '61@2x.gif'),
    Expression('62', '62@2x.gif'),
    Expression('63', '63@2x.gif'),
    Expression('64', '64@2x.gif'),
    Expression('66', '66@2x.gif'),
    Expression('67', '67@2x.gif'),
    Expression('69', '69@2x.gif'),
    Expression('72', '72@2x.gif'),
    Expression('74', '74@2x.gif'),
    Expression('75', '75@2x.gif'),
    Expression('76', '76@2x.gif'),
    Expression('77', '77@2x.gif'),
    Expression('78', '78@2x.gif'),
    Expression('79', '79@2x.gif'),
    Expression('85', '85@2x.gif'),
    Expression('86', '86@2x.gif'),
    Expression('89', '89@2x.gif'),
    Expression('90', '90@2x.gif'),
    Expression('91', '91@2x.gif'),
    Expression('96', '96@2x.gif'),
    Expression('97', '97@2x.gif'),
    Expression('98', '98@2x.gif'),
    Expression('99', '99@2x.gif'),
    Expression('100', '100@2x.gif'),
    Expression('101', '101@2x.gif'),
    Expression('102', '102@2x.gif'),
    Expression('103', '103@2x.gif'),
    Expression('104', '104@2x.gif'),
    Expression('105', '105@2x.gif'),
    Expression('106', '106@2x.gif'),
    Expression('107', '107@2x.gif'),
    Expression('108', '108@2x.gif'),
    Expression('109', '109@2x.gif'),
    Expression('110', '110@2x.gif'),
    Expression('111', '111@2x.gif'),
    Expression('112', '112@2x.gif'),
    Expression('113', '113@2x.gif'),
    Expression('114', '114@2x.gif'),
    Expression('115', '115@2x.gif'),
    Expression('116', '116@2x.gif'),
    Expression('117', '117@2x.gif'),
    Expression('118', '118@2x.gif'),
    Expression('119', '119@2x.gif'),
    Expression('120', '120@2x.gif'),
    Expression('121', '121@2x.gif'),
    Expression('122', '122@2x.gif'),
    Expression('123', '123@2x.gif'),
    Expression('124', '124@2x.gif'),
    Expression('125', '125@2x.gif'),
    Expression('126', '126@2x.gif'),
    Expression('127', '127@2x.gif'),
    Expression('128', '128@2x.gif'),
    Expression('129', '129@2x.gif'),
    Expression('130', '130@2x.gif'),
    Expression('131', '131@2x.gif'),
    Expression('132', '132@2x.gif'),
    Expression('133', '133@2x.gif'),
    Expression('134', '134@2x.gif'),
    Expression('136', '136@2x.gif'),
    Expression('137', '137@2x.gif'),
    Expression('138', '138@2x.gif'),
    Expression('139', '139@2x.gif'),
    Expression('140', '140@2x.gif'),
    Expression('141', '141@2x.gif'),
    Expression('142', '142@2x.gif'),
    Expression('143', '143@2x.gif'),
    Expression('144', '144@2x.gif'),
    Expression('145', '145@2x.gif'),
    Expression('146', '146@2x.gif'),
    Expression('147', '147@2x.gif'),
    Expression('148', '148@2x.gif'),
    Expression('149', '149@2x.gif'),
    Expression('150', '150@2x.gif'),
    Expression('151', '151@2x.gif'),
    Expression('152', '152@2x.gif'),
    Expression('153', '153@2x.gif'),
    Expression('154', '154@2x.gif'),
    Expression('155', '155@2x.gif'),
    Expression('156', '156@2x.gif'),
    Expression('157', '157@2x.gif'),
    Expression('158', '158@2x.gif'),
    Expression('159', '159@2x.gif'),
    Expression('160', '160@2x.gif'),
    Expression('161', '161@2x.gif'),
    Expression('162', '162@2x.gif'),
    Expression('163', '163@2x.gif'),
    Expression('164', '164@2x.gif'),
    Expression('165', '165@2x.gif'),
    Expression('166', '166@2x.gif'),
    Expression('167', '167@2x.gif'),
    Expression('168', '168@2x.gif'),
    Expression('169', '169@2x.gif'),
    Expression('170', '170@2x.gif'),
    Expression('171', '171@2x.gif'),
    Expression('172', '172@2x.gif'),
    Expression('173', '173@2x.gif'),
    Expression('174', '174@2x.gif'),
    Expression('175', '175@2x.gif'),
    Expression('176', '176@2x.gif'),
    Expression('177', '177@2x.gif'),
    Expression('178', '178@2x.gif'),
    Expression('179', '179@2x.gif'),
    Expression('180', '180@2x.gif'),
    Expression('181', '181@2x.gif'),
    Expression('182', '182@2x.gif'),
    Expression('183', '183@2x.gif'),
    Expression('184', '184@2x.gif'),
    Expression('185', '185@2x.gif'),
    Expression('186', '186@2x.gif'),
    Expression('187', '187@2x.gif'),
    Expression('188', '188@2x.gif'),
    Expression('189', '189@2x.gif'),
    Expression('190', '190@2x.gif'),
    Expression('191', '191@2x.gif'),
    Expression('192', '192@2x.gif'),
    Expression('193', '193@2x.gif'),
    Expression('194', '194@2x.gif'),
    Expression('197', '197@2x.gif'),
    Expression('198', '198@2x.gif'),
    Expression('199', '199@2x.gif'),
    Expression('200', '200@2x.gif'),
    Expression('201', '201@2x.gif'),
    Expression('202', '202@2x.gif'),
    Expression('203', '203@2x.gif'),
    Expression('204', '204@2x.gif'),
    Expression('205', '205@2x.gif'),
    Expression('206', '206@2x.gif'),
    Expression('207', '207@2x.gif'),
    Expression('208', '208@2x.gif'),
    Expression('209', '209@2x.gif'),
  ];

  ///kv
  static final Map<String, Expression> expressionKV = {};


  static bool isInited = false;

  ///初始化
  static void init() {
    if (isInited) {
      return;
    }

    isInited = true;
    for (var value in expressionPath) {
      expressionKV[value.name] = value;
    }

    for (var value in old) {
      expressionKV[value.name] = value;
    }
  }
}

///带有表情的文本
///备注:这里本想用自定义View直接写,因为项目太紧也没仔细研究,
///如果有人写出来也麻烦copy我一份学习学习
///这里就直接用Wrap配合Text与Image直接拼接的消息,测试了一下也不会卡;
class ExpressionText extends StatelessWidget {
  final String _text;
  final TextStyle _textStyle;

  //最大行数,默认-1,不限制
  final int maxLine;

  const ExpressionText(this._text, this._textStyle,
      {Key? key, this.maxLine = -1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (maxLine > 0)
          ? SelectableText.rich(
              TextSpan(
                children: _getContent(),
              ),
              maxLines: maxLine,
            )
          : SelectableText.rich(TextSpan(
              children: _getContent(),
            )),
    );
  }

  ///使用正则解析表情文本,使用了Text.rich替换掉了Wrap
  _getContent() {
      ExpressionData.init();
    List<InlineSpan> stack = [];

    List<int> indexList = [];

    //正则校验是否含有表情
    RegExp exp = new RegExp(r'\[.{1,4}?\]');
    if (exp.hasMatch(_text)) {
      var array = exp.allMatches(_text).toList();
      for (RegExpMatch r in array) {
        var substring = _text.substring(r.start, r.end);
        var select = substring.substring(1, substring.length - 1);
        if (ExpressionData.expressionKV.containsKey(select)) {
          indexList.add(r.start);
          indexList.add(r.end);
        }
      }
      int afterX = 0;
      for (int x = 0; x < indexList.length; x = x + 2) {
        int y = x + 1;
        var indexX = indexList[x];
        var indexY = indexList[y];
        var substring = _text.substring(afterX, indexX);
        afterX = indexY;
        stack.add(TextSpan(
          text: substring,
          style: _textStyle,
        ));
        var xy = _text.substring(indexX, indexY);
        var selectXy = xy.substring(1, xy.length - 1);
        Expression? expressionKV = ExpressionData.expressionKV[selectXy];
        if (expressionKV != null) {
          stack.add(WidgetSpan(
            child: Image(
              width: 30.0,
              height: 30.0,
              image: expressionKV.asset,
            ),
          ));
        }
      }
      if (afterX < (_text.length - 1)) {
        //拼接剩下的字符串
        var substring = _text.substring(afterX);
        stack.add(TextSpan(
          text: substring,
          style: _textStyle,
        ));
      }
    } else {
      stack.add(TextSpan(
        text: _text,
        style: _textStyle,
      ));
    }

    return stack;
  }
}
