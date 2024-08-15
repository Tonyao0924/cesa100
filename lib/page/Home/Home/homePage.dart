import 'dart:async';
import 'dart:typed_data';

import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/commonComponents/totalDialog.dart';
import 'package:cesa100/page/Home/Home/homelist.dart';
import 'package:cesa100/page/Home/Profile/profilePage.dart';
import 'package:cesa100/page/Home/Scan/scanPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ttc_ble/flutter_ttc_ble.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  double _scale2 = 1;
  late BLEDevice result;

  @override
  void initState() {
    super.initState();
    // bleProxy.addBleCallback(this);
  }

  @override
  void dispose() {
    super.dispose();
    // bleProxy.removeBleCallback(this);
  }

  // // 藍芽接受資料的func
  // @override
  // void onDataReceived(String deviceId, String serviceUuid, String characteristicUuid, Uint8List data) {
  //   if (characteristicUuid == '6e6c31cc-3bd6-fe13-124d-9611451cd8f3') {
  //     print(data);
  //     if(data[0] == 255){
  //       FlutterTtcBle.disconnect(deviceId: result.deviceId);
  //     }
  //   }else if(characteristicUuid == '6e6c31cc-3bd6-fe13-124d-9611451cd8f4'){
  //     print(data);
  //     double rawValue = ((data[0] * 0x100) + data[1]) / 100;
  //     String temperature = rawValue.toStringAsFixed(3);
  //     print('temperature');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: appBarTop, left: 10, right: 10),
              color: buttonColor,
              child: Row(
                children: [
                  const Text(
                    'Hello, Edison',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // GestureDetector(
                  //   onTapDown: (details) {
                  //     setState(() {
                  //       _scale = 0.8;
                  //     });
                  //   },
                  //   onTapUp: (details) {
                  //     setState(() {
                  //       _scale = 1.0;
                  //     });
                  //   },
                  //   onTapCancel: () {
                  //     setState(() {
                  //       _scale = 1.0;
                  //     });
                  //   },
                  //   onTap: () async {
                  //     final tmp = await Navigator.push(
                  //       context,
                  //       PageRouteBuilder(
                  //         pageBuilder: (context, animation, secondaryAnimation) => const ScanPage(),
                  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //           const begin = Offset(1.0, 0.0);
                  //           const end = Offset.zero;
                  //           const curve = Curves.ease;
                  //           var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  //           return SlideTransition(
                  //             position: animation.drive(tween),
                  //             child: child,
                  //           );
                  //         },
                  //       ),
                  //     );
                  //     print('------');
                  //     print(tmp);
                  //     if (tmp is BLEDevice) {
                  //       result = tmp;
                  //       print(result.deviceId);
                  //       FlutterTtcBle.connect(deviceId: result.deviceId).then((value) => print('已連線'));
                  //       Timer.periodic(const Duration(seconds: 1), (timer) async {
                  //         final x = await FlutterTtcBle.isConnected(deviceId: result.deviceId);
                  //         if (x) {
                  //           print('$x 連線成功');
                  //           timer.cancel();
                  //           showToast(context, '連線成功');
                  //           await writeData();
                  //           print('寫入成功');
                  //           Timer.periodic(const Duration(seconds: 1), (timer1) async {
                  //             await FlutterTtcBle.readCharacteristic(
                  //               deviceId: result.deviceId,
                  //               serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                  //               characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f3',
                  //             );
                  //             Timer(const Duration(milliseconds:500), () async {
                  //               await FlutterTtcBle.readCharacteristic(
                  //                 deviceId: result.deviceId,
                  //                 serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                  //                 characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f4',
                  //               );
                  //             });
                  //           });
                  //         } else {
                  //           print('$x 連線失敗');
                  //         }
                  //       });
                  //     } else {
                  //       print('沒有回傳藍芽');
                  //     }
                  //   },
                  //   child: Transform.scale(
                  //     scale: _scale,
                  //     child: const Image(
                  //       image: AssetImage("assets/home/plus.png"),
                  //       color: Colors.black,
                  //       fit: BoxFit.scaleDown,
                  //       alignment: Alignment.center,
                  //       height: 30.0,
                  //       width: 30.0,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        _scale2 = 0.8;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        _scale2 = 1.0;
                      });
                    },
                    onTapCancel: () {
                      // 松开手指时恢复图片原始大小
                      setState(() {
                        _scale2 = 1.0;
                      });
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Transform.scale(
                      scale: _scale2,
                      child: const Image(
                        image: AssetImage("assets/home/user.png"),
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(child: HomeList()),
            // Container(
            //   width: width * 1,
            //   height: 80,
            //   decoration: const BoxDecoration(
            //     color: buttonColor,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // 寫入資料
  Future<void> writeData() async {
    List<int> parameter = [1, 3, 10, 0, 0, 2, 88, -3, 168];
    Uint8List myData = Uint8List.fromList(parameter);
    print(myData);
    await FlutterTtcBle.writeCharacteristic(
      deviceId: result.deviceId,
      serviceUuid: '18424398-7cbc-11e9-8f9e-2a86e4085a59',
      characteristicUuid: '5a87b4ef-3bfa-76a8-e642-92933c31434f',
      value: myData,
      writeType: CharacteristicWriteType.writeNoResponse,
    ).then((value) {
      if(value == false){
        writeData();
        print('寫入data失敗');
      }else{
        print('寫入data成功');
      }
    });
  }
}
