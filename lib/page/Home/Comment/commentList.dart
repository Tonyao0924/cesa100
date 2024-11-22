import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentList extends StatefulWidget {
  final int position;
  final List<Map<String, dynamic>> markerPoints;

  const CommentList({
    super.key,
    required this.position,
    required this.markerPoints,
  });

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  late List<Map<String, dynamic>> markerPoints;
  late int position;

  @override
  void initState() {
    super.initState();
    markerPoints = widget.markerPoints.reversed.toList();
    position = widget.position;
    if (markerPoints.length > 0) {
      position = markerPoints.length - 1 - position;
    }
    print(position);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();

    if (widget.markerPoints.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'CommentList',
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'No data',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CommentList',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...List.generate(
              widget.markerPoints.length,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
                decoration: BoxDecoration(
                  color: position == index ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: width * 0.9,
                height: height * 0.2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('yyyy-MM/dd HH:mm')
                                  .format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(markerPoints[index]['x'].toString())),
                              style: TextStyle(
                                color: position == index ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'BG：${markerPoints[index]['bg']}',
                              style: TextStyle(
                                color: position == index ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 20,),

                            Text(
                              'TEMP：${markerPoints[index]['temp']}',
                              style: TextStyle(
                                color: position == index ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'desc_：', // "BG：" 的樣式
                            style: TextStyle(
                              fontSize: 16,
                              color: position == index ? Colors.white : Colors.black, // 根據需求設置文字顏色
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: markerPoints[index]['description'] != null
                                    ? _truncateText(markerPoints[index]['description'], 20)
                                    : 'Null', // 如果為 null，直接顯示空字串
                                style: TextStyle(
                                  fontSize: 16,
                                  color: position == index ? Colors.white : Colors.black, // 根據需求設置文字顏色
                                  fontWeight:
                                      markerPoints[index]['description'] != null ? FontWeight.normal : FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
