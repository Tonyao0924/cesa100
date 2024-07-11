import 'dart:async';
import 'dart:convert';

import 'package:cesa100/page/Home/Detail/editTIRPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../commonComponents/chartData.dart';
import '../Home/petlist.dart';

class DetailItem extends StatefulWidget {
  final petRowData rowData;
  const DetailItem({Key? key, required this.rowData}) : super(key: key);

  @override
  State<DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<DetailItem> {
  late ZoomPanBehavior _zoomPanBehavior;
  late TooltipBehavior _tooltipBehavior;
  late CrosshairBehavior _crosshairBehavior; // 十字線
  List<dynamic>? futureData; //讀取資料
  List<dynamic>? futureTIRData;
  List<ChartData> bloodSugarLens = []; //圖表血糖軸
  List<ChartData> temperatureLens = []; //圖表溫度軸
  List<int> displayBloodSugarTIR = [0, 0, 0, 0, 0]; //顯示血糖用的TIR
  List<int> displayTemperatureTIR = [0, 0, 0, 0, 0]; //顯示溫度用的TIR
  List<int> bloodSugarTIR = [0, 0, 0, 0, 0]; //暫存血糖資料的TIR
  List<int> temperatureTIR = [0, 0, 0, 0, 0]; //暫存溫度資料的TIR
  List<double> temperatureData = []; // TIR區分區間數據
  List<double> bloodSugarData = []; // TIR區分區間數據
  List<double> totalCurrent = []; //所有的血糖 後用來計算平均
  List<double> totalTemperature = []; //所有的溫度 後用來計算平均
  bool chooseBloodSugar = true; //判斷該顯示哪個TIR
  double avgBloodSugar = 0.0; //血糖平均
  double avgTemperature = 0.0; //溫度平均
  Timer? _debounce; //判斷停留一秒
  late DateTime minX; //座標X軸最左邊的日期時間
  late DateTime maxX; //座標X軸最右邊的日期時間
  bool firstinit = true;
  int dataCount = 0; //資料總數量
  int _chartState = 0; // 0: Both, 1: Blood Sugar, 2: Temperature
  late int firstBgNonZeroIndex;
  late int lastBgNonZeroIndex;
  late int firstTempNonZeroIndex;
  late int lastTempNonZeroIndex;

  @override
  void initState() {
    super.initState();
    drawChart();
    bloodSugarLens.clear();
    temperatureLens.clear();
    _zoomPanBehavior = ZoomPanBehavior(
      selectionRectBorderColor: Colors.red,
      selectionRectBorderWidth: 1,
      selectionRectColor: Colors.grey,
      zoomMode: ZoomMode.x,
      enablePanning: true,
      enablePinching: true,
    );
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      borderColor: Colors.red,
      borderWidth: 5,
      color: Colors.lightBlue,
    );
    _crosshairBehavior = CrosshairBehavior(
      enable: true,
      lineColor: Colors.red,
      lineDashArray: <double>[5, 5],
      lineWidth: 2,
      // lineType: CrosshairLineType.horizontal,
      shouldAlwaysShow: true,
    );
  }

  Future<void> drawChart() async {
    futureData = await fetchData();
    futureTIRData = await fetchTIRData();
    bloodSugarTIR = [0, 0, 0, 0, 0];
    temperatureTIR = [0, 0, 0, 0, 0];
    dataCount = 0;
    for (var item in futureTIRData!) {
      temperatureData.add(item['temperature_1'].toDouble());
      temperatureData.add(item['temperature_2'].toDouble());
      temperatureData.add(item['temperature_3'].toDouble());
      temperatureData.add(item['temperature_4'].toDouble());

      bloodSugarData.add(item['current_1'].toDouble());
      bloodSugarData.add(item['current_2'].toDouble());
      bloodSugarData.add(item['current_3'].toDouble());
      bloodSugarData.add(item['current_4'].toDouble());
    }
    for (var item in futureData!) {
      DateTime tmp = DateTime.parse(item['DateTime']);
      double current = item['Current_A'] is double ? item['Current_A'] : item['Current_A'].toDouble();
      double temperature = item['Temperature_C'] is double ? item['Temperature_C'] : item['Temperature_C'].toDouble();
      totalCurrent.add(current);
      totalTemperature.add(temperature);
      putTIRData(current, temperature);
      bloodSugarLens.add(ChartData(tmp, current));
      temperatureLens.add(ChartData(tmp, temperature));
      dataCount++;
    }
    if (firstinit) {
      DateTime firstTime = DateTime.parse(futureData![0]['DateTime']);
      DateTime lastTime = DateTime.parse(futureData![futureData!.length - 1]['DateTime']);
      minX = firstTime;
      maxX = lastTime;
      firstinit = false;
    }
    avgBloodSugar = totalCurrent.reduce((a, b) => a + b) / totalCurrent.length;
    avgTemperature = totalTemperature.reduce((a, b) => a + b) / totalTemperature.length;
    displayBloodSugarTIR = bloodSugarTIR;
    displayTemperatureTIR = temperatureTIR;
    setState(() {});
  }

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

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.101.101:3000/sensorData'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<dynamic>> fetchTIRData() async {
    final response = await http.get(Uri.parse('http://192.168.101.101:3000/ranges'));
    if (response.statusCode == 200) {
      // print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  void _toggleChartState() {
    setState(() {
      _chartState = (_chartState + 1) % 3;
      displayBloodSugarTIR = bloodSugarTIR;
      displayTemperatureTIR = temperatureTIR;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('123456');
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    if (_tooltipBehavior == null && _crosshairBehavior == null || futureData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              mainAxisAlignment:
                  _chartState == 1 || _chartState == 2 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                if (_chartState == 0 || _chartState == 1)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: _chartState == 0 ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.rowData.bloodSugar}',
                                  style: TextStyle(
                                    fontSize: _chartState == 1 ? 80 : 40, // 放大這裡的字體
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: 'mg/dl',
                                  style: const TextStyle(
                                    fontSize: 10, // 這裡保持原來的字體大小
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _chartState == 1 ? 50 : 20,
                          height: _chartState == 1 ? 50 : 20,
                          child: Image.asset(
                            'assets/home/arrow_-90angle.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_chartState == 0 || _chartState == 2)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: _chartState == 0 ? MainAxisAlignment.end : MainAxisAlignment.center,
                      children: [
                        if (_chartState == 0) Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.rowData.temperature}',
                                  style: TextStyle(
                                    fontSize: _chartState == 2 ? 80 : 40, // 放大這裡的字體
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ℃',
                                  style: const TextStyle(
                                    fontSize: 10, // 這裡保持原來的字體大小
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _chartState == 2 ? 50 : 20,
                          height: _chartState == 2 ? 50 : 20,
                          child: Image.asset(
                            'assets/home/arrow_45angle.png',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // 图表部分
                Positioned.fill(
                  child: Container(
                    padding: EdgeInsets.only(bottom: height * 0.03),
                    child: GestureDetector(
                      onTap: () {
                        _toggleChartState();
                      },
                      child: SfCartesianChart(
                        zoomPanBehavior: _zoomPanBehavior,
                        tooltipBehavior: _tooltipBehavior,
                        crosshairBehavior: _crosshairBehavior,
                        plotAreaBorderWidth: 2, //外框線粗度
                        onActualRangeChanged: (ActualRangeChangedArgs args) {
                          _debounce?.cancel();

                          _debounce = Timer(const Duration(milliseconds: 100), () {
                            if (args.visibleMin != 0) {
                              setState(() {
                                minX = DateTime.fromMillisecondsSinceEpoch((args.visibleMin).toInt());
                                maxX = DateTime.fromMillisecondsSinceEpoch((args.visibleMax).toInt());
                                print('------');
                                print(minX);
                                print(maxX);
                                if (futureData != null) {
                                  List<dynamic> data = futureData!;
                                  totalCurrent = [];
                                  totalTemperature = [];
                                  bloodSugarTIR = [0, 0, 0, 0, 0];
                                  temperatureTIR = [0, 0, 0, 0, 0];
                                  dataCount = 0;
                                  for (var item in data) {
                                    DateTime itemDateTime = DateTime.parse(item['DateTime']);
                                    if (itemDateTime.isAfter(minX) && itemDateTime.isBefore(maxX)) {
                                      // print('DateTime: ${item['DateTime']}, Current_A: ${item['Current_A']}, Temperature_C: ${item['Temperature_C']}, machine_id: ${item['machine_id']}');
                                      double current = item['Current_A'] is double
                                          ? item['Current_A']
                                          : item['Current_A'].toDouble();
                                      double temperature = item['Temperature_C'] is double
                                          ? item['Temperature_C']
                                          : item['Temperature_C'].toDouble();
                                      totalCurrent.add(current);
                                      totalTemperature.add(temperature);
                                      putTIRData(current, temperature);
                                      dataCount++;
                                    }
                                  }
                                  avgBloodSugar = totalCurrent.isNotEmpty
                                      ? totalCurrent.reduce((a, b) => a + b) / totalCurrent.length
                                      : 0.0;
                                  avgTemperature = totalTemperature.isNotEmpty
                                      ? totalTemperature.reduce((a, b) => a + b) / totalTemperature.length
                                      : 0.0;
                                  displayTemperatureTIR = temperatureTIR;
                                  displayBloodSugarTIR = bloodSugarTIR;
                                }
                              });
                            }
                          });
                        },
                        primaryXAxis: DateTimeAxis(
                          // intervalType: DateTimeIntervalType.minutes,
                          title: const AxisTitle(text: 'Time'),
                          rangePadding: ChartRangePadding.round,
                          initialVisibleMinimum: minX,
                          initialVisibleMaximum: maxX,
                          // autoScrollingDeltaType: DateTimeIntervalType.months, //自動滾動Delta類型
                        ),
                        primaryYAxis: NumericAxis(
                          interval: 40,
                          // interval: primaryYAxisInterval,
                          // minimum: primaryYAxisMin,
                          // maximum: primaryYAxisMax,
                          title: AxisTitle(
                            text: 'mg/dl',
                            textStyle: TextStyle(
                              color: _chartState == 0 || _chartState == 1 ? Colors.deepOrange : Colors.transparent,
                            ),
                          ),
                          labelStyle: TextStyle(
                            color: _chartState == 0 || _chartState == 1 ? Colors.deepOrange : Colors.transparent,
                          ),
                        ),
                        axes: <ChartAxis>[
                          NumericAxis(
                            name: 'secondaryYAxis',
                            opposedPosition: true,
                            // interval: secondaryYAxisInterval,
                            // minimum: secondaryYAxisMin,
                            // maximum: secondaryYAxisMax,
                            title: AxisTitle(
                              text: '℃',
                              textStyle: TextStyle(
                                color: _chartState == 0 || _chartState == 2 ? Colors.blue : Colors.transparent,
                              ),
                            ),
                            labelStyle: TextStyle(
                              color: _chartState == 0 || _chartState == 2 ? Colors.blue : Colors.transparent,
                            ),
                          ),
                        ],
                        series: <CartesianSeries>[
                          if (_chartState == 0 || _chartState == 1)
                            LineSeries<ChartData, DateTime>(
                              color: Colors.deepOrangeAccent,
                              dataSource: bloodSugarLens,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              width: 2, // 橘色值粗度
                            ),
                          if (_chartState == 0 || _chartState == 2)
                            LineSeries<ChartData, DateTime>(
                              color: Colors.blue,
                              dataSource: temperatureLens,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              yAxisName: 'secondaryYAxis',
                              name: '℃',
                              width: 2, // 藍色值粗度
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_chartState == 0 || _chartState == 1)
                  const Positioned(
                    left: 10,
                    child: Image(
                      image: AssetImage('assets/home/bloodsugar.png'),
                      fit: BoxFit.scaleDown,
                      width: 20,
                      height: 20,
                    ),
                  ),
                if (_chartState == 0 || _chartState == 2)
                  const Positioned(
                    right: 10,
                    child: Image(
                      image: AssetImage('assets/home/temperature.png'),
                      fit: BoxFit.scaleDown,
                      width: 20,
                      height: 20,
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Text(
                          'Avg. BG：\n${avgBloodSugar.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Avg. TEMP：\n${avgTemperature.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Time In Range',
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => EditTIRPage(),
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _getTextList(displayBloodSugarTIR, displayTemperatureTIR, dataCount),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  List<Widget> _getTextList(List<int> displayBloodSugarTIR, List<int> displayTemperatureTIR, int length) {
    print('1111111');
    List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.red];

    double calculatePercentage(int value, int length) {
      return length > 0 ? (value / length) * 100 : 0;
    }

    firstBgNonZeroIndex = displayBloodSugarTIR.indexWhere((value) => value > 0);
    lastBgNonZeroIndex = displayBloodSugarTIR.lastIndexWhere((value) => value > 0);
    firstTempNonZeroIndex = displayTemperatureTIR.indexWhere((value) => value > 0);
    lastTempNonZeroIndex = displayTemperatureTIR.lastIndexWhere((value) => value > 0);

    List<Widget> widgets = [];

    if (_chartState == 0 || _chartState == 1) {
      widgets.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            children: [
              Expanded(
                flex: 2,
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
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: List.generate(colors.length, (i) {
                          double percentage = calculatePercentage(displayBloodSugarTIR[i], length);
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
                                        offset: Offset(0, 2), // 阴影的偏移量
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
                      ),
                    );
                  },
                ),
              ),
              Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      );
    }

    if (_chartState == 0 || _chartState == 2) {
      widgets.add(
        SizedBox(height: 5),
      );

      widgets.add(
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            children: [
              Spacer(
                flex: 2,
              ),
              Expanded(
                flex: 14,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double maxBarWidth = constraints.maxWidth;
                    return Row(
                      children: List.generate(colors.length, (i) {
                        double percentage = calculatePercentage(displayTemperatureTIR[i], length);
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
                                      offset: Offset(0, 2), // 阴影的偏移量
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
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Align(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        ' TEMP.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }
}
