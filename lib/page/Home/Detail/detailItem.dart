import 'dart:async';
import 'dart:convert';

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
  List<ChartData> bloodSugarLens = []; //圖表血糖軸
  List<ChartData> temperatureLens = []; //圖表溫度軸
  List<int> displayBloodSugarTIR = [0, 0, 0, 0, 0]; //顯示血糖用的TIR
  List<int> displayTemperatureTIR = [0, 0, 0, 0, 0]; //顯示溫度用的TIR
  List<int> bloodSugarTIR = [0, 0, 0, 0, 0]; //暫存血糖資料的TIR
  List<int> temperatureTIR = [0, 0, 0, 0, 0]; //暫存溫度資料的TIR
  bool chooseBloodSugar = true; //判斷該顯示哪個TIR
  double avgBloodSugar = 0.0; //血糖平均
  double avgTemperature = 0.0; //溫度平均
  Timer? _debounce; //判斷停留一秒
  late DateTime minX; //座標X軸最左邊的日期時間
  late DateTime maxX; //座標X軸最右邊的日期時間
  bool firstinit = true;
  int dataCount = 0; //資料總數量
  int _chartState = 0; // 0: Both, 1: Blood Sugar, 2: Temperature

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
    List<double> totalCurrent = [];
    List<double> totalTemperature = [];
    bloodSugarTIR = [0, 0, 0, 0, 0];
    temperatureTIR = [0, 0, 0, 0, 0];
    dataCount = 0;
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
    switch (current) {
      case > 300:
        bloodSugarTIR[0]++;
        break;
      case > 200:
        bloodSugarTIR[1]++;
        break;
      case > 126:
        bloodSugarTIR[2]++;
        break;
      case > 90:
        bloodSugarTIR[3]++;
        break;
      default:
        bloodSugarTIR[4]++;
        break;
    }
    switch (temperature) {
      case > 42:
        temperatureTIR[0]++;
        break;
      case > 40:
        temperatureTIR[1]++;
        break;
      case > 38:
        temperatureTIR[2]++;
        break;
      case > 36:
        temperatureTIR[3]++;
        break;
      default:
        temperatureTIR[4]++;
        break;
    }
  }

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('http://192.168.101.101:3000/sensorData'));
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
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Image(
                        image: AssetImage(widget.rowData.src),
                        fit: BoxFit.scaleDown,
                        width: 40,
                        height: 40,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.number}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.01),
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
          Container(
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
          SizedBox(height: height * 0.01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Image(
                        image: AssetImage('assets/home/bloodsugar.png'),
                        fit: BoxFit.scaleDown,
                        width: 25,
                        height: 25,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.bloodSugar}',
                          style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'mg/dl',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/home/arrow_-90angle.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(),
                      const Image(
                        image: AssetImage('assets/home/temperature.png'),
                        fit: BoxFit.scaleDown,
                        width: 25,
                        height: 25,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.temperature} ℃',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/home/arrow_45angle.png',
                          width: 20,
                          height: 20,
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
            child: GestureDetector(
              onTap: () {
                _toggleChartState();
              },
              child: SfCartesianChart(
                zoomPanBehavior: _zoomPanBehavior,
                tooltipBehavior: _tooltipBehavior,
                crosshairBehavior: _crosshairBehavior,
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
                          List<double> totalCurrent = [];
                          List<double> totalTemperature = [];
                          bloodSugarTIR = [0, 0, 0, 0, 0];
                          temperatureTIR = [0, 0, 0, 0, 0];
                          dataCount = 0;
                          for (var item in data) {
                            DateTime itemDateTime = DateTime.parse(item['DateTime']);
                            if (itemDateTime.isAfter(minX) && itemDateTime.isBefore(maxX)) {
                              // print('DateTime: ${item['DateTime']}, Current_A: ${item['Current_A']}, Temperature_C: ${item['Temperature_C']}, machine_id: ${item['machine_id']}');
                              double current =
                                  item['Current_A'] is double ? item['Current_A'] : item['Current_A'].toDouble();
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
                    ),
                  if (_chartState == 0 || _chartState == 2)
                    LineSeries<ChartData, DateTime>(
                      color: Colors.blue,
                      dataSource: temperatureLens,
                      xValueMapper: (ChartData data, _) => data.x,
                      yValueMapper: (ChartData data, _) => data.y,
                      yAxisName: 'secondaryYAxis',
                      name: '℃',
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Text(
                  'Avg. BG：${avgBloodSugar.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                  ),
                ),
                const Spacer(),
                Text(
                  'Avg. TEMP：${avgTemperature.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getTextList(List<int> displayBloodSugarTIR, List<int> displayTemperatureTIR, int length) {
    List<String> ranges = ['>300', '200~300', '126~200', '90~126', '<90'];
    List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.red];

    double calculatePercentage(int value, int length) {
      return length > 0 ? (value / length) * 100 : 0;
    }

    int firstBgNonZeroIndex = displayBloodSugarTIR.indexWhere((value) => value > 0);
    int lastBgNonZeroIndex = displayBloodSugarTIR.lastIndexWhere((value) => value > 0);
    int firstTempNonZeroIndex = displayTemperatureTIR.indexWhere((value) => value > 0);
    int lastTempNonZeroIndex = displayTemperatureTIR.lastIndexWhere((value) => value > 0);

    return [
      Opacity(
        opacity: _chartState == 0 || _chartState == 1 ? 1.0 : 0.0,
        child: Container(
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
                        children: List.generate(ranges.length, (i) {
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
                                        blurRadius: 4.0,
                                        spreadRadius: 1.0,
                                        offset: Offset(2, 2), // 阴影的偏移量
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
      ),
      SizedBox(height: 5),
      Opacity(
        opacity: _chartState == 0 || _chartState == 2 ? 1.0 : 0.0,
        child: Container(
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
                      children: List.generate(ranges.length, (i) {
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
                                      blurRadius: 4.0,
                                      spreadRadius: 1.0,
                                      offset: Offset(2, 2), // 阴影的偏移量
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
      ),
    ];
  }

}
