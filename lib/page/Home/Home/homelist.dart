import 'dart:async';
import 'dart:typed_data';

import 'package:cesa100/commonComponents/TodoDB.dart';
import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/page/Home/Detail/detailPage.dart';
import 'package:cesa100/page/Home/Home/petlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ttc_ble/flutter_ttc_ble.dart';

import '../../../commonComponents/totalDialog.dart';
import '../Detail/time.dart';
import '../Scan/scanPage.dart';

class HomeList extends StatefulWidget {
  const HomeList({super.key});

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> with BleCallback2 {
  double _scale = 1;
  late BLEDevice result;
  String query = '';
  List<petRowData> _dataLens = dataLens;
  bool alreadyConnect = false;
  bool isDispose = false;

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;
    });
    print(query);
  }

  @override
  void initState() {
    super.initState();
    sortData();
    getData();
    bleProxy.addBleCallback(this);
  }

  @override
  void dispose() {
    super.dispose();
    isDispose = true;
    bleProxy.removeBleCallback(this);
  }

  //循環拿資料
  void getData() {
    // Timer.periodic(const Duration(seconds: 1), (timer1) async {
    //   print('拿資料');
    //   List<Map<String, dynamic>> deviceIds = await TodoDB.getAllDeviceIds();
    //   print(deviceIds);
    //   print(deviceIds.length);
    // });
  }

  // 將資料排序好
  void sortData() {
    _dataLens.sort((a, b) {
      if (a.bloodSugar > 200 || a.temperature > 40) {
        return -1;
      } else if (b.bloodSugar > 200 || b.temperature > 40) {
        return 1;
      } else {
        return 0;
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: onQueryChanged,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      _scale = 0.8;
                    });
                  },
                  onTapUp: (details) {
                    setState(() {
                      _scale = 1.0;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _scale = 1.0;
                    });
                  },
                  onTap: () async {
                    final tmp = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const ScanPage(),
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
                    print('------');
                    print(tmp);
                    if (tmp is BLEDevice) {
                      result = tmp;
                      print(result.deviceId);
                      await FlutterTtcBle.connect(deviceId: result.deviceId);
                      Timer.periodic(const Duration(seconds: 2), (timer) async {
                        bool x = await FlutterTtcBle.isConnected(deviceId: result.deviceId);
                        if (x) {
                          alreadyConnect = true;
                          String deviceIdToCheck = result.deviceId;
                          bool exists = await TodoDB.isDeviceIdExists(deviceIdToCheck);

                          if (exists) {
                            print('Device ID already exists in the database.');
                          } else {
                            print('Device ID does not exist in the database.');
                            // 你可以選擇在此處插入新的 deviceId
                            await TodoDB.insertDeviceId(deviceIdToCheck);
                          }

                          print('$x 連線成功');
                          timer.cancel();
                          showToast(context, '連線成功');
                          await writeData();
                          print('寫入成功');
                          Timer.periodic(const Duration(seconds: 1), (timer) async {
                            print(result.deviceId);
                            await FlutterTtcBle.readCharacteristic(
                              deviceId: result.deviceId,
                              serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                              characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f3',
                            ).then((value) => print(value));
                            bool x = await FlutterTtcBle.isConnected(deviceId: result.deviceId);
                            print(x);
                            if (x == false || isDispose) timer.cancel();
                            // Timer(const Duration(milliseconds: 500), () async {
                            //   await FlutterTtcBle.readCharacteristic(
                            //     deviceId: result.deviceId,
                            //     serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                            //     characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f4',
                            //   );
                            // });
                          });
                        } else {
                          print('$x 連線失敗');
                          if (alreadyConnect == false) {
                            await FlutterTtcBle.connect(deviceId: result.deviceId);
                            print(result);
                            print(result.deviceId);
                          }
                          if (isDispose) timer.cancel();
                        }
                      });
                    } else {
                      print('沒有回傳藍芽');
                    }
                  },
                  child: Transform.scale(
                    scale: _scale,
                    child: const Image(
                      image: AssetImage("assets/home/plus.png"),
                      color: Colors.black,
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
          Expanded(
            child: ListView.builder(
              itemCount: _dataLens.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        splashFactory: NoSplash.splashFactory,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        minimumSize: Size(width * 1, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                DetailPage(rowData: _dataLens[index]),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage(_dataLens[index].src),
                                    fit: BoxFit.scaleDown,
                                    width: 35,
                                    height: 35,
                                  ),
                                  Text(
                                    '${dataLens[index].number}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40
                                            ? Colors.red
                                            : Colors.black)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage('assets/home/bloodsugar.png'),
                                    fit: BoxFit.scaleDown,
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text(
                                    '${dataLens[index].bloodSugar}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40
                                            ? Colors.red
                                            : Colors.black)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Image(
                                    image: AssetImage('assets/home/temperature.png'),
                                    fit: BoxFit.scaleDown,
                                    width: 30,
                                    height: 30,
                                  ),
                                  Text(
                                    '${dataLens[index].temperature}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40
                                            ? Colors.red
                                            : Colors.black)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                        ],
                      )
                      // Text(
                      //   '${dataLens[index].number}',
                      // ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 寫入機器的parameter
  Future<void> writeData() async {
    final DateTime now = DateTime.now();
    Time time =
        Time(year: now.year, month: now.month, day: now.day, hour: now.hour, minute: now.minute, second: now.second);
    Uint8List encodedTime = encodeTime(time);
    // print('encodeTime(time)');
    // print(encodedTime);
    List<int> parameter = List.generate(9, (index) => 2);
    // List<int> parameter = [0, 0, 0, 0, 3, 2, 88, -3, 168];
    parameter[0] = 0x01;
    parameter[1] = 3000 >> 8; // Quiet Time (High Byte)
    parameter[2] = 3000 & 0xFF; // Quiet Time (Low Byte)
    parameter[3] = 3 >> 8; // Sample Interval (High Byte)
    parameter[4] = 3 & 0xFF; // Sample Interval (Low Byte)
    parameter[5] = 1 >> 8; // Running Count (High Byte)
    parameter[6] = 1 & 0xFF; // Running Count (Low Byte)
    parameter[7] = 100 >> 8; // Init E (High Byte)
    parameter[8] = 100 & 0xFF; // Init E (Low Byte)
    parameter.addAll(encodedTime.toList());
    Uint8List myData = Uint8List.fromList(parameter);
    print('-------');
    print(parameter);
    print(myData);
    await FlutterTtcBle.writeCharacteristic(
      deviceId: result.deviceId,
      serviceUuid: '18424398-7cbc-11e9-8f9e-2a86e4085a59',
      characteristicUuid: '5a87b4ef-3bfa-76a8-e642-92933c31434f',
      value: myData,
      writeType: CharacteristicWriteType.writeNoResponse,
    ).then((value) {
      if (value == false) {
        writeData();
        print('寫入data失敗');
      } else {
        print('寫入data成功');
      }
    });
  }

  Uint8List encodeTime(Time time) {
    // 為減少傳輸封包, 因此年份限制在 00~99 兩位數, 當編碼時, 應減掉 2000, ex:2024-2000=24
    int encodedTime = ((time.year - 2000) & 0x3F) << 26 |
        (time.month & 0x0F) << 22 |
        (time.day & 0x1F) << 17 |
        (time.hour & 0x1F) << 12 |
        (time.minute & 0x3F) << 6 |
        (time.second & 0x3F);

    return Uint8List(4)
      ..[0] = (encodedTime >> 24) & 0xFF

      ..[1] = (encodedTime >> 16) & 0xFF
      ..[2] = (encodedTime >> 8) & 0xFF
      ..[3] = encodedTime & 0xFF;
  }

  Time decodeTime(Uint8List buffer) {
    int encodedTime = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] << 8) | buffer[3];

    // 為減少傳輸封包, 因此年份限制在 00~99 兩位數, 當還原時, 應加上 2000, ex:24+2000=2024
    return Time(
      year: ((encodedTime >> 26) & 0x3F) + 2000,
      month: (encodedTime >> 22) & 0x0F,
      day: (encodedTime >> 17) & 0x1F,
      hour: (encodedTime >> 12) & 0x1F,
      minute: (encodedTime >> 6) & 0x3F,
      second: encodedTime & 0x3F,
    );
  }

  // Read data in this Func.
  @override
  void onDataReceived(String deviceId, String serviceUuid, String characteristicUuid, Uint8List data) {
    print(characteristicUuid);
    if (characteristicUuid == '6e6c31cc-3bd6-fe13-124d-9611451cd8f3') {
      print(data);
      if (data[0] > 4 || data[0] < 1) {
        FlutterTtcBle.disconnect(deviceId: result.deviceId);
      } else {
        var bytes = data;
        for (int i = 0; i < bytes[0]; i++) {
          int index = i * 8;
          Uint8List dataX =
              Uint8List.fromList([bytes[index + 1], bytes[index + 2], bytes[index + 3], bytes[index + 4]]);
          Time timeX = decodeTime(dataX);
          double y = (0.9 - ((bytes[index + 5] * 0x100 + bytes[index + 6]).toDouble() / 1000)) /
              100000; // 電壓(mV) 轉換成 電流 (A)
          double t = (((bytes[index + 7] * 0x100 + bytes[index + 8]).toDouble() / 100)); // 溫度
          print('時間：$timeX 電流：$y 溫度：$t');
        }
      }
    } else if (characteristicUuid == '6e6c31cc-3bd6-fe13-124d-9611451cd8f4') {
      print(data);
      double rawValue = ((data[0] * 0x100) + data[1]) / 100;
      String temperature = rawValue.toStringAsFixed(3);
      print('temperature');
    }
  }
}
