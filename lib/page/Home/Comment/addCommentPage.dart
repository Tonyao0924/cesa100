import 'dart:convert';
import 'dart:typed_data';

import 'package:cesa100/commonComponents/addData.dart';
import 'package:cesa100/commonComponents/totalDialog.dart';
import 'package:cesa100/page/Home/Comment/commentList.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../commonComponents/constants.dart';

class AddCommentPage extends StatefulWidget {
  final int lastId;
  final int lastBG;
  final double lastTEMP;
  final String lastTime;
  final String description;
  final String imagePath;
  final List<Map<String, dynamic>> markerPoints;

  const AddCommentPage({
    super.key,
    required this.lastId,
    required this.lastBG,
    required this.lastTEMP,
    required this.lastTime,
    required this.description,
    required this.imagePath,
    required this.markerPoints,
  });

  @override
  State<AddCommentPage> createState() => _AddCommentPageState();
}

class _AddCommentPageState extends State<AddCommentPage> {
  ScrollController _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController(); // description 敘述
  Uint8List? _image;
  StorageService storageService = StorageService();
  final firebaseStorage = FirebaseStorage.instance;
  bool _isWaiting = false;
  int position = 0; // id位置
  bool leftBlue = false; //左邊箭頭
  bool rightBlue = false; // 右邊箭頭
  late int lastId;
  late int lastBG;
  late double lastTEMP;
  late String lastTime;
  late String description;
  late String imagePath;
  late String initialDescription; //用來判斷是否被修改
  bool imageChange = false;
  bool okBlue = false;

  @override
  void initState() {
    super.initState();
    lastId = widget.lastId;
    lastBG = widget.lastBG;
    lastTEMP = widget.lastTEMP;
    lastTime = widget.lastTime;
    _textEditingController.text = widget.description;
    imagePath = widget.imagePath;
    initialDescription = widget.description;
    if (widget.markerPoints.length > 0) {
      position = findNowTimePosition(DateTime.parse(lastTime), widget.markerPoints);
      if (position >= 0 && widget.markerPoints.isNotEmpty) {
        // 正數情況：找到精確匹配
        if (position >= 1) leftBlue = true; // 不是第一個點
        if (position < widget.markerPoints.length - 1) rightBlue = true; // 不是最後一個點
      } else {
        // 負數情況：未找到，表示插入點
        int insertIndex = -(position);
        if (insertIndex > 1) leftBlue = true; // 可以插入在索引 0 之後，左側有效
        if (insertIndex <= widget.markerPoints.length) rightBlue = true; // 插入點在範圍內，右側有效
      }
    }
    print(widget.markerPoints);
    print(widget.markerPoints.length);
    print(position);
  }

  void isModified() {
    okBlue = imageChange || _textEditingController.text != initialDescription;
    setState(() {});
  }

  // 二分搜尋法
  int findNowTimePosition(DateTime lastTime, List<Map<String, dynamic>> markerPoints) {
    int low = 0; //
    int high = widget.markerPoints.length - 1;
    while (low <= high) {
      int mid = (low + high) ~/ 2;
      DateTime midX = markerPoints[mid]['x'];

      if (lastTime == midX) {
        return mid; // 找到剛好匹配的點
      } else if (lastTime.isBefore(midX)) {
        high = mid - 1;
      } else {
        low = mid + 1;
      }
    }

    // 如果沒有剛好匹配，low 和 high 是最接近的兩個索引
    return -(low + 1); // 返回負值表示未找到，但提供插入點 +1的用意是因為-0 = 0
  }

  Future<int> _sendPutRequest() async {
    try {
      String? description = _textEditingController.text.isEmpty ? null : _textEditingController.text;
      String? imageUrl = imagePath.isEmpty ? null : imagePath;

      final response = await http.put(
        Uri.parse('http://172.16.200.77:3000/comment/${lastId}'), // 將 id 加入 URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'description': description, // 可以更新 description
          'image_path': imageUrl, // 可以更新 image_path
        }),
      );

      // 返回狀態碼
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // 捕捉異常時返回 500 表示內部錯誤
    }
  }

  Future<void> selectImage() async {
    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  Uint8List? img = await pickImage(ImageSource.camera);
                  if (img != null) {
                    setState(() {
                      _image = img;
                      imageChange = true;
                      isModified();
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  Uint8List? img = await pickImage(ImageSource.gallery);
                  if (img != null) {
                    setState(() {
                      _image = img;
                      imageChange = true;
                      isModified();
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source);
    if (_file != null) {
      return await _file.readAsBytes();
    }
  }

  void saveAnnotate() async {
    print('save image.');
  }

  Future<String> uploadImageToFirebase() async {
    String downloadUrl = '';

    if (_image == null) {
      print('No image selected');
      return downloadUrl;
    }

    try {
      String filePath = 'annotateImage/${DateTime.now()}.png';
      await firebaseStorage.ref(filePath).putData(_image!);

      downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      print('Image uploaded to Firebase: $downloadUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }

    return downloadUrl;
  }

  void updateMarkerDetails(int position) {
    setState(() {
      lastId = widget.markerPoints[position]['id'];
      lastBG = widget.markerPoints[position]['bg'];
      lastTEMP = widget.markerPoints[position]['temp'].toDouble();
      lastTime = widget.markerPoints[position]['x'].toString();
      _textEditingController.text = widget.markerPoints[position]['description'] ?? '';
      imagePath = widget.markerPoints[position]['image_path'] ?? '';
      initialDescription = _textEditingController.text;
      imageChange = false;
      leftBlue = position > 0 ? true : false;
      rightBlue = position < widget.markerPoints.length - 1 ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Add Comment',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.history,  // 使用 history 圖示
            //     color: Colors.black, // 圖示顏色設置為黑色
            //     size: 28, // 圖示大小
            //   ),
            //   onPressed: () {
            //     // 點擊後執行的操作，例如打開歷史紀錄頁面
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CommentList(),  // 假設你有一個 HistoryPage
            //       ),
            //     );
            //   },
            // ),
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
                if (okBlue) {
                  bool? confirmResult = await confirmDialog(context);
                  if (confirmResult == true) {
                    setState(() {
                      _isWaiting = true;
                    });
                    if (_image != null && imagePath == '') {
                      imagePath = await uploadImageToFirebase();
                      print(imagePath);
                    }
                    print(imagePath);
                    var result = await _sendPutRequest();
                    setState(() {
                      _isWaiting = false;
                    });
                    if (result == 200) {
                      // showToast(context, 'Modification Successful');
                      Navigator.pop(context, lastTime); // 關閉當前頁面
                    } else {
                      showToast(context, 'Modification Failed');
                    }
                  }
                }
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: okBlue == true ? Colors.blue : Colors.black12,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            if (leftBlue) {
                              okBlue = false;
                              if (position < 0) {
                                position += 1;
                                position = position.abs(); // 將負數轉為正數
                              }
                              position -= 1;
                              print(position);
                              updateMarkerDetails(position);
                            }
                          },
                          child: Text.rich(
                            WidgetSpan(
                              child: Icon(
                                Icons.chevron_left,
                                size: 30,
                                color: leftBlue ? Colors.blue : Colors.black12,
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(width: 10), // 添加空間使文字之間不會太擁擠
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), // 添加內邊距讓顯示效果更好
                          child: Text(
                            // 使用 DateFormat 將時間轉換為 '月/日 時:分' 格式
                            DateFormat('MM/dd HH:mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(lastTime)),
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Spacer(),

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
                            if (rightBlue) {
                              okBlue = false;
                              position += 1;
                              if (position < 0) {
                                position = position.abs(); // 將負數轉為正數
                              }

                              print(position);
                              updateMarkerDetails(position);
                            }
                          },
                          child: Text.rich(
                            WidgetSpan(
                              child: Icon(
                                Icons.chevron_right,
                                size: 30,
                                color: rightBlue ? Colors.blue : Colors.black12,
                              ),
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
                            text: 'BG：', // "BG：" 的樣式
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black, // 根據需求設置文字顏色
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${lastBG}', // `lastBG` 數值的樣式
                                style: TextStyle(
                                  fontSize: 30, // 設置較大的字體
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green, // 根據需求設置文字顏色
                                ),
                              ),
                              TextSpan(
                                text: 'mg/dl', // `lastBG` 數值的樣式
                                style: TextStyle(
                                  fontSize: 12, // 設置較大的字體
                                  color: Colors.black, // 根據需求設置文字顏色
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        RichText(
                          text: TextSpan(
                            text: 'TEMP：', // "TEMP：" 的樣式
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black, // 根據需求設置文字顏色
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${lastTEMP}', // `lastTEMP` 數值的樣式
                                style: TextStyle(
                                  fontSize: 24, // 設置較大的字體
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue, // 根據需求設置文字顏色
                                ),
                              ),
                              TextSpan(
                                text: ' ℃', // 溫度單位的樣式
                                style: TextStyle(
                                  fontSize: 12, // 設置較小的字體
                                  color: Colors.black, // 根據需求設置文字顏色
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
                      Spacer(),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                          ),
                          borderRadius: BorderRadius.circular(10), // 邊框圓角
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            splashFactory: NoSplash.splashFactory,
                            padding: EdgeInsets.zero, // 去除按鈕內邊距
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommentList(
                                  position: position,
                                  markerPoints: widget.markerPoints.reversed.toList() ?? [],
                                ),
                              ),
                            );
                            if (result != null) {
                              print(result);
                              position = result;
                              updateMarkerDetails(position);
                            }
                          },
                          child: Image.asset(
                            'assets/home/history.png', // 自定義圖片的路徑
                            height: 48,
                            width: 48,
                            color: Colors.black,
                            fit: BoxFit.cover, // 根據需求調整圖片的顯示方式
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    padding: EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: Scrollbar(
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
                        onChanged: (value) {
                          isModified();
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Text(
                        'Image:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: width * 0.6,
                    height: width * 0.6,
                    child: TextButton(
                      style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith(
                          (states) {
                            return states.contains(MaterialState.pressed) ? iconHoverColor : iconColor;
                          },
                        ),
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () async {
                        selectImage();
                      },
                      child: imagePath != null && imagePath.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imagePath,
                                width: width * 0.6,
                                height: width * 0.6,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // 圖片載入完成，返回圖片
                                  }
                                  return Center(
                                    child: SizedBox(
                                      width: width * 0.1,
                                      height: width * 0.1,
                                      child: CircularProgressIndicator(),
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
                          : (_image == null
                              ? Text.rich(
                                  WidgetSpan(
                                    child: ImageIcon(
                                      AssetImage(
                                        "assets/home/image_plus.png",
                                      ),
                                      color: Colors.black12,
                                      size: width * 0.5,
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    _image!,
                                    width: width * 0.6,
                                    height: width * 0.6,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                    ),
                  ),
                ],
              ),
            ),
            _isWaiting
                ? Center(
                    child: Container(
                      height: width / 5,
                      width: width / 5,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CupertinoActivityIndicator(
                        animating: true,
                        radius: width / 15,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   elevation: 0,
        //   child: Image.asset(
        //     'assets/home/history.png', // 自定義圖片的路徑
        //     fit: BoxFit.cover, // 根據需求調整圖片的顯示方式
        //   ),
        //   onPressed: () async {
        //     final result = await Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => CommentList(
        //           position: position,
        //           markerPoints: widget.markerPoints.reversed.toList() ?? [],
        //         ),
        //       ),
        //     );
        //     if (result != null) {
        //       print(result);
        //       position = result;
        //       updateMarkerDetails(position);
        //     }
        //   },
        // ),
      ),
    );
  }

  Future<bool?> confirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CupertinoAlertDialog(
          content: Container(
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '您確定修改嗎？',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text(
                '否',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text(
                '是',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
