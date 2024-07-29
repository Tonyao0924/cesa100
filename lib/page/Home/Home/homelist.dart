import 'dart:async';
import 'dart:typed_data';

import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/page/Home/Detail/detailPage.dart';
import 'package:cesa100/page/Home/Home/petlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ttc_ble/flutter_ttc_ble.dart';

import '../../../commonComponents/totalDialog.dart';
import '../Scan/scanPage.dart';

class HomeList extends StatefulWidget {
  const HomeList({super.key});

  @override
  State<HomeList> createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  double _scale = 1;
  late BLEDevice result;
  String query = '';
  List<petRowData> _dataLens = dataLens;

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
  }

  // 將資料排序好
  void sortData(){
    _dataLens.sort((a, b) {
      if (a.bloodSugar > 200 || a.temperature > 40) {
        return -1;
      }
      else if (b.bloodSugar > 200 || b.temperature > 40) {
        return 1;
      }
      else {
        return 0;
      }
    });
    setState(() {

    });
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
                      FlutterTtcBle.connect(deviceId: result.deviceId).then((value) => print('已連線'));
                      Timer.periodic(const Duration(seconds: 1), (timer) async {
                        final x = await FlutterTtcBle.isConnected(deviceId: result.deviceId);
                        if (x) {
                          print('$x 連線成功');
                          timer.cancel();
                          showToast(context, '連線成功');
                          await writeData();
                          print('寫入成功');
                          Timer.periodic(const Duration(seconds: 1), (timer1) async {
                            await FlutterTtcBle.readCharacteristic(
                              deviceId: result.deviceId,
                              serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                              characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f3',
                            );
                            Timer(const Duration(milliseconds:500), () async {
                              await FlutterTtcBle.readCharacteristic(
                                deviceId: result.deviceId,
                                serviceUuid: '184247d0-7cbc-11e9-089e-2a86e4085a59',
                                characteristicUuid: '6e6c31cc-3bd6-fe13-124d-9611451cd8f4',
                              );
                            });
                          });
                        } else {
                          print('$x 連線失敗');
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
                          pageBuilder: (context, animation, secondaryAnimation) => DetailPage(rowData: _dataLens[index]),
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
                                    color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
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
                                      color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
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
                                      color: (dataLens[index].bloodSugar >= 200 || dataLens[index].temperature >= 40 ? Colors.red : Colors.black)
                                  ),
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
