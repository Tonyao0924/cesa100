import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import '../../../commonComponents/constants.dart';

class AddCommentPage extends StatefulWidget {
  final int lastId;
  final int lastBG;
  final double lastTEMP;
  final String lastTime;
  const AddCommentPage({
    super.key,
    required this.lastId,
    required this.lastBG,
    required this.lastTEMP,
    required this.lastTime,
  });

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Comment',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  return states.contains(MaterialState.pressed) ? iconHoverColor : iconColor;
                },
              ),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            onPressed: () async {
              print('165156');
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Text(
                  'Time',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))
                  ),
                  child:Text(
                    '${widget.lastTime}',

                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: 'BG：',  // "BG：" 的樣式
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,  // 根據需求設置文字顏色
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${widget.lastBG}',  // `lastBG` 數值的樣式
                        style: TextStyle(
                          fontSize: 24,  // 設置較大的字體
                          fontWeight: FontWeight.bold,
                          color: Colors.green,  // 根據需求設置文字顏色
                        ),
                      ),
                      TextSpan(
                        text: 'mg/dl',  // `lastBG` 數值的樣式
                        style: TextStyle(
                          fontSize: 12,  // 設置較大的字體
                          color: Colors.black,  // 根據需求設置文字顏色
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  'TEMP：${widget.lastTEMP}',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
