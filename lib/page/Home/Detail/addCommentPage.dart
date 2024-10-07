import 'dart:convert';
import 'dart:typed_data';

import 'package:cesa100/commonComponents/addData.dart';
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
  Uint8List? _image;
  StorageService storageService = StorageService();
  final firebaseStorage = FirebaseStorage.instance;
  String imagePath = '';

  Future<int> _sendPutRequest() async {
    try {
      String? description = _textEditingController.text.isEmpty ? null : _textEditingController.text;
      String? imageUrl = imagePath.isEmpty ? null : imagePath;

      final response = await http.put(
        Uri.parse('http://172.16.200.77:3000/comment/${widget.lastId}'), // 將 id 加入 URL
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
                  Uint8List img = await pickImage(ImageSource.camera);
                  setState(() {
                    _image = img;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  Uint8List img = await pickImage(ImageSource.gallery);
                  setState(() {
                    _image = img;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
    // Uint8List img = await pickImage(ImageSource.camera);
    // setState(() {
    //   _image = img;
    // });
    // print(_image);
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

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
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
                if(_image != null && imagePath == ''){
                  imagePath = await uploadImageToFirebase();
                  print(imagePath);
                }
                print(imagePath);
                var result = await _sendPutRequest();
                // print(result);
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
        body: SingleChildScrollView(
          child: Column(
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
                    SizedBox(width: 10), // 添加空間使文字之間不會太擁擠
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), // 添加內邊距讓顯示效果更好
                      child: Text(
                        // 使用 DateFormat 將時間轉換為 '月/日 時:分' 格式
                        DateFormat('MM/dd HH:mm').format(DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.lastTime)),
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
                        text: 'BG：', // "BG：" 的樣式
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black, // 根據需求設置文字顏色
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${widget.lastBG}', // `lastBG` 數值的樣式
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
                            text: '${widget.lastTEMP}', // `lastTEMP` 數值的樣式
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
                    // onChanged: (value) {
                    //   WidgetsBinding.instance.addPostFrameCallback((_) {
                    //     // _updateThumbPosition(); // Update the scroll thumb position and height
                    //   });
                    // },
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
                  selectImage();
                  // String result = await storageService.uploadImage();
                  // print(result);
                },
                child: _image == null
                    ? Text.rich(
                        WidgetSpan(
                          child: ImageIcon(
                            AssetImage("assets/home/image.png"), // 顯示默認的圖片圖標
                            size: 200,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10), // 設置圓角半徑為 10
                        child: Image.memory(
                          _image!, // 如果有圖片，則顯示選中的圖片
                          width: width * 0.6,
                          height: width * 0.6,
                          fit: BoxFit.cover, // 確保圖片填滿容器
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
