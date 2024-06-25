import 'dart:convert';

import 'package:cesa100/commonComponents/totalDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../commonComponents/constants.dart';

class EditTIRPage extends StatefulWidget {
  final List<int> bloodSugarTIR;
  final List<int> temperatureTIR;
  final List<double> temperatureData;
  final List<double> bloodSugarData;
  final int dataCount;
  final List<double> totalCurrent;
  final List<double> totalTemperature;

  const EditTIRPage({
    Key? key,
    required this.bloodSugarTIR,
    required this.temperatureTIR,
    required this.temperatureData,
    required this.bloodSugarData,
    required this.dataCount,
    required this.totalCurrent,
    required this.totalTemperature,
  }) : super(key: key);

  @override
  State<EditTIRPage> createState() => _EditTIRPageState();
}

class _EditTIRPageState extends State<EditTIRPage> {
  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.red];
  late int firstBgNonZeroIndex;
  late int lastBgNonZeroIndex;
  late int firstTempNonZeroIndex;
  late int lastTempNonZeroIndex;
  late List<int> bloodSugarTIR;
  late List<int> temperatureTIR;
  late List<double> temperatureData;
  late List<double> bloodSugarData;
  late List<double> totalCurrent;
  late List<double> totalTemperature;

  @override
  void initState() {
    super.initState();
    firstBgNonZeroIndex = widget.bloodSugarTIR.indexWhere((value) => value > 0);
    lastBgNonZeroIndex = widget.bloodSugarTIR.lastIndexWhere((value) => value > 0);
    firstTempNonZeroIndex = widget.temperatureTIR.indexWhere((value) => value > 0);
    lastTempNonZeroIndex = widget.temperatureTIR.lastIndexWhere((value) => value > 0);
    bloodSugarTIR = List<int>.from(widget.bloodSugarTIR);
    temperatureTIR = List<int>.from(widget.temperatureTIR);
    temperatureData = List<double>.from(widget.temperatureData);
    bloodSugarData = List<double>.from(widget.bloodSugarData);
    totalCurrent = List<double>.from(widget.totalCurrent);
    totalTemperature = List<double>.from(widget.totalTemperature);
  }

  void recalculateData() {
    setState(() {
      bloodSugarTIR = List<int>.filled(bloodSugarData.length + 1, 0);
      temperatureTIR = List<int>.filled(temperatureData.length + 1, 0);
      for (int i = 0; i < totalCurrent.length; i++) {
        for (int j = 0; j < bloodSugarData.length; j++) {
          if (bloodSugarData[j] < totalCurrent[i]) {
            bloodSugarTIR[j]++;
            break;
          }
          if (j == bloodSugarData.length - 1) {
            bloodSugarTIR[j + 1]++;
          }
        }
      }
      for (int i = 0; i < totalTemperature.length; i++) {
        for (int j = 0; j < temperatureData.length; j++) {
          if (temperatureData[j] < totalTemperature[i]) {
            temperatureTIR[j]++;
            break;
          }
          if (j == temperatureData.length - 1) {
            temperatureTIR[j+1]++;
          }
        }
      }
      print(temperatureTIR);
      firstBgNonZeroIndex = bloodSugarTIR.indexWhere((value) => value > 0);
      lastBgNonZeroIndex = bloodSugarTIR.lastIndexWhere((value) => value > 0);
      firstTempNonZeroIndex = temperatureTIR.indexWhere((value) => value > 0);
      lastTempNonZeroIndex = temperatureTIR.lastIndexWhere((value) => value > 0);
    });
  }

  double calculatePercentage(int value, int length) {
    return length > 0 ? (value / length) * 100 : 0;
  }

  Future<int> _showPicker(BuildContext context, int initialValue) async {
    int selectedValue = initialValue;
    int? result = await showCupertinoModalPopup<int>(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Text('OK'),
                    onPressed: () {
                      print(selectedValue);
                      Navigator.of(context).pop(selectedValue);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: initialValue),
                itemExtent: 32.0,
                onSelectedItemChanged: (int value) {
                  selectedValue = value;
                },
                children: List<Widget>.generate(501, (index) {
                  return Center(
                    child: Text('$index'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? initialValue; // 返回選擇的值，如果結果為空則返回初始值
  }

  Future<double> _showTemperaturePicker(BuildContext context, double initialValue) async {
    double selectedValue = initialValue;
    int initialItem = ((initialValue - 20.0) * 10).toInt(); // 将初始值转换为索引
    double? result = await showCupertinoModalPopup<double>(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            Container(
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.all(0),
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(selectedValue);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 180,
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(initialItem: initialItem),
                itemExtent: 32.0,
                onSelectedItemChanged: (int value) {
                  selectedValue = 20.0 + value / 10;
                },
                children: List<Widget>.generate(((60.0 - 20.0) * 10 + 1).toInt(), (index) {
                  return Center(
                    child: Text('${(20.0 + index / 10).toStringAsFixed(1)}'),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? initialValue; // 返回選擇的值，如果結果為空則返回初始值
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit TIR',
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
              Map<String, dynamic> data = {
                "machine_id": 1,
                "temperature_1": temperatureData[0],
                "temperature_2": temperatureData[1],
                "temperature_3": temperatureData[2],
                "temperature_4": temperatureData[3],
                "current_1": bloodSugarData[0],
                "current_2": bloodSugarData[1],
                "current_3": bloodSugarData[2],
                "current_4": bloodSugarData[3],
              };
              print(data);
              final response = await http.put(
                Uri.parse('http://192.168.101.101:3000/modifyranges'),
                headers: {
                  'Content-Type': 'application/json',
                },
                body: jsonEncode(data),
              );

              if (response.statusCode == 200) {
                print('數據已成功發送');
                showToast(context, 'Edit success');
                Navigator.pop(context);
              } else {
                print('發送數據失敗：${response.statusCode}');
                showToast(context, 'Edit error');
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xffff8bb8),
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          // ElevatedButton(
          //   onPressed: () {
          //     print(totalTemperature.length);
          //   },
          //   child: Text('test'),
          // ),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'BG. ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double maxBarWidth = constraints.maxWidth;
                            return Row(
                              children: List.generate(5, (i) {
                                double percentage = calculatePercentage(bloodSugarTIR[i], widget.dataCount);
                                final tmpWidth = (maxBarWidth * percentage / 100).clamp(0.0, maxBarWidth);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: tmpWidth,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colors[i],
                                          borderRadius: BorderRadius.horizontal(
                                            left: i == firstBgNonZeroIndex ? Radius.circular(5) : Radius.zero,
                                            right: i == lastBgNonZeroIndex ? Radius.circular(5) : Radius.zero,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10.0,
                                              spreadRadius: 1.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: percentage >= 10
                                              ? Text(
                                                  '${percentage.toStringAsFixed(0)}%',
                                                  style: TextStyle(fontSize: 8, color: Colors.white),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  bloodSugarTIR.length,
                  (i) => Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: GestureDetector(
                                  onTap: () async {
                                    int index = (i == bloodSugarData.length) ? i - 1 : i;
                                    final tmp = await _showPicker(context, bloodSugarData[index].toInt());
                                    setState(() {
                                      if (tmp > bloodSugarData[index]) {
                                        bloodSugarData[index] = tmp.toDouble();
                                        int previousIndex = index - 1;
                                        while (previousIndex >= 0 &&
                                            bloodSugarData[previousIndex] <=
                                                bloodSugarData[previousIndex + 1]) {
                                          bloodSugarData[previousIndex] =
                                              bloodSugarData[previousIndex + 1] + 1;
                                          previousIndex--;
                                        }
                                      } else if (tmp < bloodSugarData[index]) {
                                        bloodSugarData[index] = tmp.toDouble();
                                        int nextIndex = index + 1;
                                        while (nextIndex < bloodSugarData.length &&
                                            bloodSugarData[nextIndex - 1] <= bloodSugarData[nextIndex]) {
                                          bloodSugarData[nextIndex] = bloodSugarData[nextIndex - 1] - 1;
                                          nextIndex++;
                                        }
                                      }
                                      recalculateData();
                                    });
                                  },
                                  child: Text(
                                    (i == bloodSugarData.length)
                                        ? '<${bloodSugarData.last.toStringAsFixed(0)} : '
                                        : '>=${bloodSugarData[i].toStringAsFixed(0)} : ',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxBarWidth = constraints.maxWidth;
                                double percentage = calculatePercentage(bloodSugarTIR[i], widget.dataCount);
                                return Row(
                                  children: [
                                    Container(
                                      width: maxBarWidth * percentage / 100,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: colors[i],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: percentage >= 10
                                            ? Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: TextStyle(fontSize: 8, color: Colors.white),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'TEMP. ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 14,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double maxBarWidth = constraints.maxWidth;
                            return Row(
                              children: List.generate(5, (i) {
                                double percentage = calculatePercentage(temperatureTIR[i], widget.dataCount);
                                final tmpWidth = (maxBarWidth * percentage / 100).clamp(0.0, maxBarWidth);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: tmpWidth,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: colors[i],
                                          borderRadius: BorderRadius.horizontal(
                                            left: i == firstTempNonZeroIndex ? Radius.circular(5) : Radius.zero,
                                            right: i == lastTempNonZeroIndex ? Radius.circular(5) : Radius.zero,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10.0,
                                              spreadRadius: 1.0,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: percentage >= 10
                                              ? Text(
                                                  '${percentage.toStringAsFixed(0)}%',
                                                  style: TextStyle(fontSize: 8, color: Colors.white),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  temperatureTIR.length,
                  (i) => Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: GestureDetector(
                                  onTap: () async {
                                    int index = (i == temperatureData.length) ? i - 1 : i;
                                    final tmp = await _showTemperaturePicker(context, temperatureData[index]);
                                    setState(() {
                                      if (tmp > temperatureData[index]) {
                                        temperatureData[index] = tmp;
                                        int previousIndex = index - 1;
                                        while (previousIndex >= 0 &&
                                            temperatureData[previousIndex] <=
                                                temperatureData[previousIndex + 1]) {
                                          temperatureData[previousIndex] =
                                              temperatureData[previousIndex + 1] + 0.1;
                                          previousIndex--;
                                        }
                                      } else if (tmp < temperatureData[index]) {
                                        temperatureData[index] = tmp;
                                        int nextIndex = index + 1;
                                        while (nextIndex < temperatureData.length &&
                                            temperatureData[nextIndex - 1] <=
                                                temperatureData[nextIndex]) {
                                          temperatureData[nextIndex] =
                                              temperatureData[nextIndex - 1] - 0.1;
                                          nextIndex++;
                                        }
                                        if (index == temperatureData.length - 1) {
                                          i = index - 1;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    i == temperatureData.length
                                        ? '<${temperatureData.last.toStringAsFixed(1)} : '
                                        : '>=${temperatureData[i].toStringAsFixed(1)} : ',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxBarWidth = constraints.maxWidth;
                                double percentage = calculatePercentage(temperatureTIR[i], widget.dataCount);
                                return Row(
                                  children: [
                                    Container(
                                      width: maxBarWidth * percentage / 100,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: colors[i],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: percentage >= 10
                                            ? Text(
                                                '${percentage.toStringAsFixed(0)}%',
                                                style: TextStyle(fontSize: 8, color: Colors.white),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}
