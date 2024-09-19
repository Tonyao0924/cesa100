import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';


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
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
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
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 10),  // 添加空間使文字之間不會太擁擠
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), // 添加內邊距讓顯示效果更好
                    child: Text(
                      // 使用 DateFormat 將時間轉換為 '月/日 時:分' 格式
                      DateFormat('MM/dd HH:mm').format(
                          DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.lastTime)
                      ),
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
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
                            fontSize: 30,  // 設置較大的字體
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
                  RichText(
                    text: TextSpan(
                      text: 'TEMP：',  // "TEMP：" 的樣式
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,  // 根據需求設置文字顏色
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: '${widget.lastTEMP}',  // `lastTEMP` 數值的樣式
                          style: TextStyle(
                            fontSize: 24,  // 設置較大的字體
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,  // 根據需求設置文字顏色
                          ),
                        ),
                        TextSpan(
                          text: ' ℃',  // 溫度單位的樣式
                          style: TextStyle(
                            fontSize: 12,  // 設置較小的字體
                            color: Colors.black,  // 根據需求設置文字顏色
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(horizontal: 5,),
              child:  Scrollbar(
                controller: _scrollController,
                child: TextFormField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Enter description here...',
                    border: InputBorder.none,
                    // counterText: '',
                  ),
                  // onChanged: (value) {
                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                  //     // _updateThumbPosition(); // Update the scroll thumb position and height
                  //   });
                  // },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
