import 'dart:convert';

import 'package:cesa100/commonComponents/totalDialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For http requests

import '../../../commonComponents/constants.dart';
import 'editTIRDialog.dart';

class EditTIRPage extends StatefulWidget {
  final List<int> displayBloodSugarTIR;
  final List<int> displayTemperatureTIR;
  final List<double> totalCurrent;
  final List<double> totalTemperature;
  final int dataCount;
  final List<double> bloodSugarData;
  final List<double> temperatureData;
  const EditTIRPage(
      {Key? key,
      required this.displayBloodSugarTIR,
      required this.displayTemperatureTIR,
      required this.totalCurrent,
      required this.totalTemperature,
      required this.dataCount,
      required this.bloodSugarData,
      required this.temperatureData})
      : super(key: key);

  @override
  State<EditTIRPage> createState() => _EditTIRPageState();
}

class _EditTIRPageState extends State<EditTIRPage> {
  List<int> data = [0, 2, 98, 0, 0]; // 目前的資料，以百分比表示
  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.red];
  late List<double> displayBloodSugarTIR;
  late List<double> displayTemperatureTIR;
  late List<double> bloodSugarData;
  late List<double> temperatureData;
  List<int> bloodSugarTIR = [0, 0, 0, 0, 0]; //暫存血糖資料的TIR
  List<int> temperatureTIR = [0, 0, 0, 0, 0]; //暫存溫度資料的TIR

  double calculatePercentage(int value, int length) {
    return length > 0 ? (value / length) * 100 : 0;
  }

  @override
  void initState() {
    super.initState();
    displayBloodSugarTIR = [];
    displayTemperatureTIR = [];
    bloodSugarData = widget.bloodSugarData;
    temperatureData = widget.temperatureData;

    print(bloodSugarData);
    bloodSugarTIR = widget.displayBloodSugarTIR;
    temperatureTIR = widget.displayTemperatureTIR;
    for (int i = 0; i < widget.displayTemperatureTIR.length; i++) {
      displayBloodSugarTIR.add(calculatePercentage(widget.displayBloodSugarTIR[i], widget.dataCount));
      displayTemperatureTIR.add(calculatePercentage(widget.displayTemperatureTIR[i], widget.dataCount));
    }
    print(widget.displayTemperatureTIR);
  }

  // 放資料到TIR陣列當中
  void putTIRData(double current, double temperature) {
    if (current >= bloodSugarData[0]) {
      bloodSugarTIR[0]++;
    } else if (current >= bloodSugarData[1]) {
      bloodSugarTIR[1]++;
    } else if (current >= bloodSugarData[2]) {
      bloodSugarTIR[2]++;
    } else if (current >= bloodSugarData[3]) {
      bloodSugarTIR[3]++;
    } else {
      bloodSugarTIR[4]++;
    }
    if (temperature >= temperatureData[0]) {
      temperatureTIR[0]++;
    } else if (temperature >= temperatureData[1]) {
      temperatureTIR[1]++;
    } else if (temperature >= temperatureData[2]) {
      temperatureTIR[2]++;
    } else if (temperature >= temperatureData[3]) {
      temperatureTIR[3]++;
    } else {
      temperatureTIR[4]++;
    }
  }

  Future<bool> updateRanges() async {
    final url = Uri.parse('http://172.16.200.77:3000/modifyranges');

    // 準備要發送的數據
    final data = {
      "machine_id": 1,
      "temperature_1": temperatureData[0],
      "temperature_2": temperatureData[1],
      "temperature_3": temperatureData[2],
      "temperature_4": temperatureData[3],
      "current_1": bloodSugarData[0],
      "current_2": bloodSugarData[1],
      "current_3": bloodSugarData[2],
      "current_4": bloodSugarData[3]
    };

    try {
      // 發送 PUT 請求
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data), // 將數據編碼為 JSON 格式
      );

      if (response.statusCode == 200) {
        // 成功回應
        print('資料已成功更新');
        return true;
      } else {
        // 處理非 200 狀態碼
        print('更新失敗，狀態碼: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // 捕捉異常
      print('發生錯誤: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          IconButton(
            onPressed: () async {
              bool putSuccess = await updateRanges();
              if(putSuccess){
                showToast(context, '資料更新成功');
              }else{
                showToast(context, '資料更新失敗');
              }
              print('資料庫更新資料');
              List<int> resultTIR = bloodSugarTIR + temperatureTIR;
              Navigator.of(context).pop(resultTIR); // 返回選擇的數值
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      Text(
                        'Blood Glucos：',
                        style: TextStyle(
                          fontSize: 18,
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
                          var returnData = await openEditBGTIRDialog(context, bloodSugarData);
                          if (returnData != null) {
                            setState(() {
                              bloodSugarData = returnData;
                            });
                            print(bloodSugarData);
                            bloodSugarTIR = [0, 0, 0, 0, 0];
                            for(int i = 0 ; i < widget.totalCurrent.length ; i++){
                              double current = widget.totalCurrent[i];
                              if (current <= bloodSugarData[0]) {
                                bloodSugarTIR[0]++;
                              } else if (current <= bloodSugarData[1]) {
                                bloodSugarTIR[1]++;
                              } else if (current <= bloodSugarData[2]) {
                                bloodSugarTIR[2]++;
                              } else if (current <= bloodSugarData[3]) {
                                bloodSugarTIR[3]++;
                              } else {
                                bloodSugarTIR[4]++;
                              }
                            }
                            print(bloodSugarTIR);
                            displayBloodSugarTIR.clear();
                            for (int i = 0; i < bloodSugarTIR.length; i++) {
                              displayBloodSugarTIR.add(calculatePercentage(bloodSugarTIR[i], widget.dataCount));
                            }
                          }
                        },
                        child: Text.rich(
                          WidgetSpan(
                            child: Icon(
                              Icons.settings,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250, // 控制圖表的寬度
                      height: 250, // 控制圖表的高度
                      child: CustomPaint(
                        painter:
                            BarChartPainter2('Blood Glucos：', 'mg/dl', displayBloodSugarTIR, colors, bloodSugarData),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      Text(
                        'Temperature：',
                        style: TextStyle(
                          fontSize: 18,
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
                          var returnData = await openEditTEMPTIRDialog(context, temperatureData);
                          if (returnData != null) {
                            setState(() {
                              temperatureData = returnData;
                            });
                            temperatureTIR = [0, 0, 0, 0, 0];
                            for(int i = 0 ; i < widget.totalTemperature.length ; i++){
                              double current = widget.totalTemperature[i];
                              if (current <= temperatureData[0]) {
                                temperatureTIR[0]++;
                              } else if (current <= temperatureData[1]) {
                                temperatureTIR[1]++;
                              } else if (current <= temperatureData[2]) {
                                temperatureTIR[2]++;
                              } else if (current <= temperatureData[3]) {
                                temperatureTIR[3]++;
                              } else {
                                temperatureTIR[4]++;
                              }
                            }
                            displayTemperatureTIR.clear();
                            for (int i = 0; i < temperatureTIR.length; i++) {
                              displayTemperatureTIR.add(calculatePercentage(temperatureTIR[i], widget.dataCount));
                            }
                          }
                        },
                        child: Text.rich(
                          WidgetSpan(
                            child: Icon(
                              Icons.settings,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250, // 控制圖表的寬度
                      height: 250, // 控制圖表的高度
                      child: CustomPaint(
                        painter: BarChartPainter2('Temperature：', '℃', displayTemperatureTIR, colors, temperatureData),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BarChartPainter2 extends CustomPainter {
  final String title;
  final String unit;
  final List<double> data;
  final List<Color> colors;
  final List<double> labels;

  BarChartPainter2(this.title, this.unit, this.data, this.colors, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    double totalHeight = size.height;
    double totalWidth = size.width;
    double spacing = 0; // 每個區間之間的間距
    List<double> location = [0, 0, 0];
    double currentX = 0;
    double labelHeight = 200; // 刻度文字的高度
    double barHeight = totalHeight - labelHeight; // 值條的高度
    double separatorWidth = 2; // 分隔線的寬度
    double firstHigh = 0.0;
    double lastHigh = 0.0;
    double tmp = 0.0; // 暫存值

    // 計算刻度文字的垂直位置
    List<double> labelXPositions = [];

    for (int i = 0; i < data.length; i++) {
      double barWidth = data[i] > 0 ? data[i] * (totalWidth - spacing * (data.length - 1)) / 100 : 1; // 如果數值為0，顯示寬度為1
      Color barColor = data[i] > 0 ? colors[i] : Colors.grey; // 如果數值為0，顏色設置為灰色
      Paint barPaint = Paint()..color = barColor;
      if (i != 0 && i != 1) {
        location[i - 2] = (currentX + tmp) / 2;
      }
      tmp = currentX;
      // 繪製值條
      canvas.drawRect(
        Rect.fromLTWH(currentX, totalHeight - 100, barWidth, 50),
        barPaint,
      );

      currentX += barWidth;
      double offsetX = currentX - separatorWidth / 2 - 16 / 2;
      if (i == 0) {
        firstHigh = offsetX;
      }
      if (i == data.length - 1) {
        lastHigh = offsetX;
      }

      labelXPositions.add(offsetX);

      // 繪製分隔線
      if (i < data.length - 1) {
        currentX += separatorWidth + spacing;
        Paint separatorPaint = Paint()..color = Colors.transparent;
        canvas.drawRect(
          Rect.fromLTWH(currentX, totalHeight - barHeight, separatorWidth, barHeight),
          separatorPaint,
        );
      }
    }

    // 調整刻度文字的位置，防止溢出
    double maxYPosition = labelXPositions.reduce((value, element) => value > element ? value : element);
    double minYPosition = labelXPositions.reduce((value, element) => value < element ? value : element);
    double overflowTop = totalHeight - maxYPosition;
    double overflowBottom = minYPosition;
    if (overflowTop < 0) {
      labelXPositions = labelXPositions.map((pos) => pos - overflowTop).toList();
    }

    if (overflowBottom < 0) {
      labelXPositions = labelXPositions.map((pos) => pos + overflowBottom).toList();
    }
    if (labelXPositions[0] < firstHigh) labelXPositions[0] = firstHigh;
    for (int i = 1; i < labels.length; i++) {
      if (labelXPositions[i] - labelXPositions[i - 1] < 35) {
        labelXPositions[i] = labelXPositions[i - 1] + 35;
      }
    }

    if (labelXPositions[3] > lastHigh) {
      labelXPositions[3] = lastHigh;
    }
    for (int i = labels.length - 2; i >= 0; i--) {
      if ((labelXPositions[i + 1] - labelXPositions[i]) < 35) {
        labelXPositions[i] = labelXPositions[i + 1] - 35;
      }
    }

    bool isTemperature = (title == 'Temperature：');
    // 繪製刻度文字
    for (int i = 0; i < labels.length; i++) {
      if (i < labelXPositions.length) {
        drawTextBtn(
          canvas,
          labels[i],
          Offset(labelXPositions[i], 220),
          TextStyle(color: Colors.black, fontSize: 16),
          isTemperature: isTemperature, // 傳遞 isTemperature 參數
        );
      }
    }

    // print(location);
    if (location[0] < 25) {
      location[0] = 25;
    }

    for (int i = 1; i < location.length; i++) {
      if (location[i] - location[i - 1] <= 50) {
        location[i] = location[i - 1] + 50;
      }
    }

    if (location[2] > 235) {
      location[2] = 235;
    }

    for (int i = 1; i >= 0; i--) {
      if (location[i + 1] - location[i] <= 50) {
        location[i] = location[i + 1] - 50;
      }
    }

    // print(location);
    if (data.isNotEmpty) {
      //繪製虛線
      drawFoldedLine(canvas, Offset(0, barHeight * 3.5), 90);
      drawstraightLine(canvas, Offset(location[0], barHeight + 80), 45);
      drawMidStraightLine(canvas, Offset(location[1], barHeight + 80), 90);
      drawstraightLine(canvas, Offset(location[2], barHeight + 80), 45);
      drawEndFoldedLine(canvas, Offset(totalWidth + 12, barHeight * 3.5), 90);
      //繪製文字
      // drawTextNoCenter(canvas, title, Offset(-50, 10), TextStyle(color: Colors.black, fontSize: 18)); // 繪製title
      drawText(canvas, 'Low+', Offset(-30, barHeight * 3), TextStyle(color: Colors.black54, fontSize: 14));
      drawText(canvas, 'Low', Offset(location[0], barHeight * 2.6), TextStyle(color: Colors.black54, fontSize: 14));
      drawText(canvas, 'Target', Offset(location[1], barHeight * 2.6), TextStyle(color: Colors.black54, fontSize: 14));
      drawText(canvas, 'High', Offset(location[2], barHeight * 2.6), TextStyle(color: Colors.black54, fontSize: 14));
      drawText(canvas, 'High+', Offset(290, barHeight * 3), TextStyle(color: Colors.black54, fontSize: 14));
      drawText(canvas, unit, Offset(290, 222), TextStyle(color: Colors.black87, fontSize: 12));
      //   //繪製百分比
      drawText(canvas, '${data[0].toStringAsFixed(0)}%', Offset(0, barHeight + 15),
          TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[1].toStringAsFixed(0)}%', Offset(location[0], barHeight + 15),
          TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[3].toStringAsFixed(0)}%', Offset(location[2], barHeight + 15),
          TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[4].toStringAsFixed(0)}%', Offset(272, barHeight + 15),
          TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.bold));
      // 畫data0跟data1的蓋子 畫data3跟data4的蓋子
      drawLine(canvas, -6, location[0]);
      drawLine(canvas, location[2], 268);
      // 繪製最上方的三個百分比
      drawText(canvas, '${(data[0] + data[1]).toStringAsFixed(0)}%', Offset((location[0]) / 2, 10),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
      drawText(canvas, '${(data[2]).toStringAsFixed(0)}%', Offset(location[1], 10),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
      drawText(canvas, '${(data[3] + data[4]).toStringAsFixed(0)}%', Offset((272 + location[2]) / 2, 10),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
    }
  }

  // 繪製文字
  void drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final TextSpan span = TextSpan(text: text, style: style);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    // 调整偏移量以使文字水平居中
    final double textWidth = tp.width;
    final Offset centeredOffset = Offset(offset.dx - textWidth / 2, offset.dy);
    tp.paint(canvas, centeredOffset);
  }

  void drawTextNoCenter(Canvas canvas, String text, Offset offset, TextStyle style) {
    final TextSpan span = TextSpan(text: text, style: style);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    // 直接使用傳入的 offset，不再進行偏移調整
    tp.paint(canvas, offset);
  }

  // 繪製文字按鈕
  void drawTextBtn(Canvas canvas, double text, Offset offset, TextStyle style, {bool isTemperature = false}) {
    String toText = isTemperature ? text.toStringAsFixed(1) : text.toStringAsFixed(0);
    final TextSpan span = TextSpan(text: toText, style: style);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    // 调整偏移量以使文字水平居中
    final double textWidth = tp.width;
    final Offset centeredOffset = Offset(offset.dx - textWidth / 2, offset.dy);
    tp.paint(canvas, centeredOffset);
  }

  // 繪製最左邊的虛像
  void drawFoldedLine(Canvas canvas, Offset start, double height) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = start;
    while (current.dx > start.dx - 6) {
      canvas.drawLine(current, Offset(current.dx - dashHeight, current.dy), paint);
      current = Offset(current.dx - (dashHeight + dashSpace), current.dy);
    }

    // print(current.dy);
    // print(start.dy - height);
    while (current.dy > start.dy - height) {
      double remainingSpace = current.dy - (start.dy - height);

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx, current.dy - remainingSpace), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx, current.dy - dashHeight), paint);
        current = Offset(current.dx, current.dy - (dashHeight + dashSpace));
      }
    }
  }

  // 繪製第二條跟第四條虛線
  void drawstraightLine(Canvas canvas, Offset start, double height) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = Offset(start.dx, start.dy); // 调整起始高度，使其与其他方法相同

    // print(current.dy);
    // print(start.dy - height);
    while (current.dy > start.dy - height) {
      double remainingSpace = current.dy - (start.dy - height);

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx, current.dy - remainingSpace), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx, current.dy - dashHeight), paint);
        current = Offset(current.dx, current.dy - (dashHeight + dashSpace));
      }
    }
  }

  // 繪製中線
  void drawMidStraightLine(Canvas canvas, Offset start, double height) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = Offset(start.dx, start.dy); // 起始高度

    while (current.dy > start.dy - height) {
      double remainingSpace = (start.dy + height) - current.dy;

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx, current.dy - remainingSpace), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx, current.dy - dashHeight), paint);
        current = Offset(current.dx, current.dy - (dashHeight + dashSpace));
      }
    }
  }

  // 繪製最右邊的虛線
  void drawEndFoldedLine(Canvas canvas, Offset start, double height) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = start;
    while (current.dx < start.dx + 6) {
      canvas.drawLine(current, Offset(current.dx + dashHeight, current.dy), paint);
      current = Offset(current.dx + (dashHeight + dashSpace), current.dy);
    }

    while (current.dy > start.dy - height) {
      double remainingSpace = current.dy - (start.dy - height);

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx, current.dy - remainingSpace), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx, current.dy - dashHeight), paint);
        current = Offset(current.dx, current.dy - (dashHeight + dashSpace));
      }
    }
  }

  //繪製上面的實線
  void drawLine(Canvas canvas, double start, double end) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    Offset startO = Offset(start, 60);
    canvas.drawLine(startO, Offset(startO.dx, startO.dy - 20), paint);
    startO = Offset(startO.dx, startO.dy - 20);
    canvas.drawLine(startO, Offset(startO.dx + (end - start), startO.dy), paint);
    startO = Offset(startO.dx + (end - start), startO.dy);
    canvas.drawLine(startO, Offset(startO.dx, startO.dy + 20), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final List<String> labels;

  BarChartPainter(this.data, this.colors, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    double totalHeight = size.height;
    double totalWidth = size.width;
    double currentY = 0; //圖表高度
    double separatorHeight = 2; // 分隔線的高度
    double spacing = 0; // 每個區間之間的間距
    double labelWidth = 30; // 刻度文字的寬度
    double barWidth = totalWidth - labelWidth; // 值條的寬度
    double firstHigh = 0.0;
    double lastHigh = 0.0;
    double tmp = 0.0; // 暫存值
    List<double> location = [0, 0, 0];

    // 計算刻度文字的垂直位置數組
    List<double> labelYPositions = [];

    for (int i = 0; i < data.length; i++) {
      double barHeight = data[i] > 0 ? data[i] * (totalHeight - spacing * (data.length - 1)) / 100 : 1; // 如果數值為0，顯示高度為1

      Color barColor = data[i] > 0 ? colors[i] : Colors.grey; // 如果數值為0，顏色設置為灰色

      Paint barPaint = Paint()..color = barColor;
      // print(currentY);
      if (i != 0 && i != 1) {
        location[i - 2] = (currentY + tmp) / 2;
      }
      tmp = currentY;
      // 繪製值條
      canvas.drawRect(
        Rect.fromLTWH(labelWidth, currentY, barWidth / 5, barHeight),
        barPaint,
      );

      currentY += barHeight;
      // 計算刻度文字的垂直位置
      double offsetY = currentY - separatorHeight / 2 - 16 / 2;
      if (i == 0) {
        firstHigh = offsetY;
      }
      if (i == data.length - 1) {
        lastHigh = offsetY;
      }

      labelYPositions.add(offsetY);

      // 繪製分隔線
      if (i < data.length - 1) {
        currentY += separatorHeight + spacing;
        Paint separatorPaint = Paint()..color = Colors.transparent;
        canvas.drawRect(
          Rect.fromLTWH(labelWidth, currentY, barWidth, separatorHeight),
          separatorPaint,
        );
      }
    }
    // 調整刻度文字的位置，防止溢出
    double maxYPosition = labelYPositions.reduce((value, element) => value > element ? value : element);
    double minYPosition = labelYPositions.reduce((value, element) => value < element ? value : element);
    double overflowTop = totalHeight - maxYPosition;
    double overflowBottom = minYPosition;
    if (overflowTop < 0) {
      labelYPositions = labelYPositions.map((pos) => pos - overflowTop).toList();
    }

    if (overflowBottom < 0) {
      labelYPositions = labelYPositions.map((pos) => pos + overflowBottom).toList();
    }
    if (labelYPositions[0] < firstHigh) labelYPositions[0] = firstHigh;
    for (int i = 1; i < labels.length; i++) {
      if (labelYPositions[i] - labelYPositions[i - 1] < 25) {
        labelYPositions[i] = labelYPositions[i - 1] + 25;
      }
    }

    if (labelYPositions[3] > lastHigh) {
      labelYPositions[3] = lastHigh;
    }
    for (int i = labels.length - 2; i >= 0; i--) {
      if ((labelYPositions[i + 1] - labelYPositions[i]) < 25) {
        labelYPositions[i] = labelYPositions[i + 1] - 25;
      }
    }

    // 繪製刻度文字
    for (int i = 0; i < labels.length; i++) {
      if (i < labelYPositions.length) {
        drawText(
          canvas,
          labels[i],
          Offset(-5, labelYPositions[i]),
          TextStyle(color: Colors.black, fontSize: 16),
        );
      }
    }

    if (location[0] < 25) {
      location[0] = 25;
    }

    for (int i = 1; i < location.length; i++) {
      if (location[i] - location[i - 1] <= 30) {
        location[i] = location[i - 1] + 30;
      }
    }

    if (location[2] > 285) {
      location[2] = 285;
    }

    for (int i = 1; i >= 0; i--) {
      if (location[i + 1] - location[i] <= 30) {
        location[i] = location[i + 1] - 30;
      }
    }

    // print(location);
    if (data.isNotEmpty) {
      //繪製虛線
      drawFoldedLine(canvas, Offset(barWidth / 5, 0), totalWidth / 2 - 20);
      drawstraightLine(canvas, Offset(barWidth / 5, location[0]), totalWidth / 2 - 20);
      drawMidStraightLine(canvas, Offset(barWidth / 3, location[1]), totalWidth / 2);
      drawstraightLine(canvas, Offset(barWidth / 5, location[2]), totalWidth / 2 - 20);
      drawEndFoldedLine(canvas, Offset(barWidth / 5, 310), totalWidth / 2 - 20);
      //繪製文字
      drawText(canvas, 'Very High', Offset(barWidth / 5 + 40, -40), TextStyle(color: Colors.black54, fontSize: 16));
      drawText(
          canvas, 'High', Offset(barWidth / 5 + 40, location[0] - 10), TextStyle(color: Colors.black54, fontSize: 16));
      drawText(canvas, 'Target', Offset(barWidth / 5 + 40, location[1] - 10),
          TextStyle(color: Colors.black54, fontSize: 16));
      drawText(
          canvas, 'Low', Offset(barWidth / 5 + 40, location[2] - 10), TextStyle(color: Colors.black54, fontSize: 16));
      drawText(canvas, 'Very Low', Offset(barWidth / 5 + 40, 320), TextStyle(color: Colors.black54, fontSize: 16));
      //繪製百分比
      drawText(canvas, '${data[0].toStringAsFixed(0)}%', Offset(barWidth - 80, -20),
          TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[1].toStringAsFixed(0)}%', Offset(barWidth - 80, location[0] - 10),
          TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[3].toStringAsFixed(0)}%', Offset(barWidth - 80, location[2] - 10),
          TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold));
      drawText(canvas, '${data[4].toStringAsFixed(0)}%', Offset(barWidth - 80, 310),
          TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold));

      drawLine(canvas, -10, location[0]);
      drawLine(canvas, location[2], 320);
      drawText(canvas, '${(data[0] + data[1]).toStringAsFixed(0)}%', Offset(250, (-10 + location[0]) / 2 - 12),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
      drawText(canvas, '${(data[2]).toStringAsFixed(0)}%', Offset(250, location[1] - 12),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
      drawText(canvas, '${(data[3] + data[4]).toStringAsFixed(0)}%', Offset(250, (320 + location[2]) / 2 - 12),
          TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold));
    }
  }

  void drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final TextSpan span = TextSpan(text: text, style: style);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  void drawFoldedLine(Canvas canvas, Offset start, double width) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = start;
    while (current.dy > start.dy - 10) {
      canvas.drawLine(current, Offset(current.dx, current.dy - dashHeight), paint);
      current = Offset(current.dx, current.dy - (dashHeight + dashSpace));
    }

    current = Offset(current.dx, start.dy - 10);

    while (current.dx < start.dx + width) {
      double remainingSpace = (start.dx + width) - current.dx;

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx + remainingSpace, current.dy), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx + dashHeight, current.dy), paint);
        current = Offset(current.dx + (dashHeight + dashSpace), current.dy);
      }
    }
  }

  void drawstraightLine(Canvas canvas, Offset start, double width) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = Offset(start.dx + (width / 1.7), start.dy);

    while (current.dx < start.dx + width) {
      double remainingSpace = (start.dx + width) - current.dx;

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx + remainingSpace, current.dy), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx + dashHeight, current.dy), paint);
        current = Offset(current.dx + (dashHeight + dashSpace), current.dy);
      }
    }
  }

  void drawMidStraightLine(Canvas canvas, Offset start, double width) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = Offset(start.dx + (width / 2.5), start.dy);

    while (current.dx < start.dx + width) {
      double remainingSpace = (start.dx + width) - current.dx;

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx + remainingSpace, current.dy), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx + dashHeight, current.dy), paint);
        current = Offset(current.dx + (dashHeight + dashSpace), current.dy);
      }
    }
  }

  void drawEndFoldedLine(Canvas canvas, Offset start, double width) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    double dashHeight = 4.0;
    double dashSpace = 2.0;

    Offset current = start;
    while (current.dy < start.dy + 10) {
      canvas.drawLine(current, Offset(current.dx, current.dy + dashHeight), paint);
      current = Offset(current.dx, current.dy + (dashHeight + dashSpace));
    }

    current = Offset(current.dx, start.dy + 10);

    while (current.dx < start.dx + width) {
      double remainingSpace = (start.dx + width) - current.dx;

      if (remainingSpace < dashHeight) {
        canvas.drawLine(current, Offset(current.dx + remainingSpace, current.dy), paint);
        break;
      } else {
        canvas.drawLine(current, Offset(current.dx + dashHeight, current.dy), paint);
        current = Offset(current.dx + (dashHeight + dashSpace), current.dy);
      }
    }
  }

  void drawLine(Canvas canvas, double start, double end) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    Offset startO = Offset(225, start);
    canvas.drawLine(startO, Offset(startO.dx + 20, startO.dy), paint);
    startO = Offset(startO.dx + 20, startO.dy);
    canvas.drawLine(startO, Offset(startO.dx, startO.dy + (end - start)), paint);
    startO = Offset(startO.dx, startO.dy + (end - start));
    canvas.drawLine(startO, Offset(startO.dx - 20, startO.dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
