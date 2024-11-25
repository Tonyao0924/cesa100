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
  ScrollController _controller = ScrollController();
  late List<Map<String, dynamic>> displayedPoints; // 當前顯示的資料
  bool _isLoading = false;
  late int selectedIndex;



  @override
  void initState() {
    super.initState();
    markerPoints = widget.markerPoints;
    position = widget.position;
    if (markerPoints.length > 0) {
      position = markerPoints.length - 1 - position;
    }

    // 初始化顯示資料
    displayedPoints = markerPoints.sublist(position, (position + 30).clamp(0, markerPoints.length));
    print(displayedPoints[0]);

    selectedIndex = 0;
    _controller.addListener(_onScroll);
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   double height = MediaQuery.of(context).size.height;
  //   double itemHeight = height * 0.24;
  //
  //   // 初始化 ScrollController
  //   _controller = ScrollController(initialScrollOffset: itemHeight * selectedIndex);
  //   _controller.addListener(() {
  //     print(_controller.offset);
  //   });
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.position.pixels >= _controller.position.maxScrollExtent - 30 && !_isLoading) {
      // 滾到底部時載入更多
      _loadMoreData(isScrollDown: true);
    } else if (_controller.position.pixels <= 30 && !_isLoading) {
      // 滾到頂部時載入更多
      _loadMoreData(isScrollDown: false);
    }
  }

  void _loadMoreData({required bool isScrollDown}) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 模擬載入延遲
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        int startIndex;
        int endIndex;

        if (isScrollDown) {
          startIndex = markerPoints.indexOf(displayedPoints.last) + 1;
          endIndex = (startIndex + 30).clamp(0, markerPoints.length);
        } else {
          endIndex = markerPoints.indexOf(displayedPoints.first);
          startIndex = (endIndex - 30).clamp(0, markerPoints.length);
          if (startIndex < 0) startIndex = 0;

          print('向上載入的數量: ${endIndex - startIndex}');
          selectedIndex = selectedIndex + (endIndex - startIndex);
          if(endIndex - startIndex != 0){
            double height = MediaQuery.of(context).size.height;
            double itemHeight = height * 0.24;
            _controller.jumpTo(itemHeight * (endIndex - startIndex));
          }
        }

        if (startIndex < endIndex) {
          final newPoints = markerPoints.sublist(startIndex, endIndex);
          if (isScrollDown) {
            displayedPoints.addAll(newPoints);
          } else {
            displayedPoints.insertAll(0, newPoints);
          }
          print('$startIndex $endIndex');
        }

        _isLoading = false;
      });
    });
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
        controller: _controller,
        child: ListView.builder(
          shrinkWrap: true, // 適配 SingleChildScrollView
          physics: NeverScrollableScrollPhysics(), // 禁止內部滾動，使用外部滾動
          itemExtent: height * 0.24,
          itemCount: displayedPoints.length,
          itemBuilder: (context, index) {
            final point = displayedPoints[index];
            return GestureDetector(
              onTap: () {
                print(point);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                margin: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
                decoration: BoxDecoration(
                  color: selectedIndex == index ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: width * 0.9,
                height: height * 0.2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // foregroundColor: buttonBackgroundColor,
                    backgroundColor: selectedIndex == index ? Colors.blue : Colors.white,
                    splashFactory: NoSplash.splashFactory,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: (){

                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      displayedPoints[index]['image_path'] != null &&
                          displayedPoints[index]['image_path'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                displayedPoints[index]['image_path'],
                                width: width * 0.2,
                                height: width * 0.2,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // 圖片載入完成，返回圖片
                                  }
                                  return Center(
                                    child: SizedBox(
                                      width: width * 0.2,
                                      height: width * 0.2,
                                      child: Padding(
                                        padding: EdgeInsets.all(width * 0.05),
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      '圖片載入失敗',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ); // 載入失敗顯示提示
                                },
                              ),
                            )
                          : Text.rich(
                              WidgetSpan(
                                child: ImageIcon(
                                  AssetImage(
                                    "assets/home/image_plus.png",
                                  ),
                                  color: Colors.black12,
                                  size: width * 0.2,
                                ),
                              ),
                            ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('yyyy-MM/dd HH:mm').format(
                                  DateFormat('yyyy-MM-dd HH:mm:ss').parse(displayedPoints[index]['x'].toString()),
                                ),
                                style: TextStyle(
                                  color: selectedIndex == index ? Colors.white : Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'BG：${displayedPoints[index]['bg']}',
                                style: TextStyle(
                                  color: selectedIndex == index ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Text(
                                'TEMP：${displayedPoints[index]['temp']}',
                                style: TextStyle(
                                  color: selectedIndex == index ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          RichText(
                            text: TextSpan(
                              text: 'desc_：', // "BG：" 的樣式
                              style: TextStyle(
                                fontSize: 16,
                                color: selectedIndex == index ? Colors.white : Colors.black, // 根據需求設置文字顏色
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: displayedPoints[index]['description'] != null
                                      ? _truncateText(displayedPoints[index]['description'], 15)
                                      : 'Null', // 如果為 null，直接顯示空字串
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: selectedIndex == index ? Colors.white : Colors.black, // 根據需求設置文字顏色
                                    fontWeight:
                                    displayedPoints[index]['description'] != null ? FontWeight.normal : FontWeight.bold,
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
            );
          },
        ),
      ),
    );
  }
}
