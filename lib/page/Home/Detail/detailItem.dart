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
  late TrackballBehavior _trackballBehavior;
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
    _trackballBehavior = TrackballBehavior(
      // Enables the trackball
      enable: false,
      tooltipSettings: const InteractiveTooltip(enable: true, color: Colors.red),
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
    if (_tooltipBehavior == null && _trackballBehavior == null && _crosshairBehavior == null || futureData == null) {
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chooseBloodSugar ? Colors.blue : Colors.white,
                      splashFactory: NoSplash.splashFactory,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(width * 0.3, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(width: 1, color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        chooseBloodSugar = true;
                      });
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Blood sugar',
                        style: TextStyle(
                          color: chooseBloodSugar ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.15),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chooseBloodSugar ? Colors.white : Colors.blue,
                      splashFactory: NoSplash.splashFactory,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(width * 0.3, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(width: 1, color: Colors.black),
                    ),
                    onPressed: () {
                      setState(() {
                        chooseBloodSugar = false;
                      });
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Temperature',
                        style: TextStyle(
                          color: chooseBloodSugar ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _getTextList(chooseBloodSugar, displayBloodSugarTIR, displayTemperatureTIR, dataCount),
                ),
              ],
            ),
          ),
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
                          '${widget.rowData.bloodSugar} mg/dl',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Image.asset(
                          'assets/home/arrow_90angle.png',
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
                          'assets/home/arrow_90angle.png',
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
                trackballBehavior: _trackballBehavior,
                crosshairBehavior: _crosshairBehavior,
                onActualRangeChanged: (ActualRangeChangedArgs args) {
                  _debounce?.cancel();

                  _debounce = Timer(const Duration(milliseconds: 100), () {
                    if (args.visibleMin != 0) {
                      setState(() {
                        minX = DateTime.fromMillisecondsSinceEpoch((args.visibleMin).toInt());
                        maxX = DateTime.fromMillisecondsSinceEpoch((args.visibleMax).toInt());

                        // if (chooseBloodSugar) {
                        //   visibleBloodSugarData = bloodSugarLens.where((data) => data.x.isAfter(minX) && data.x.isBefore(maxX)).toList();
                        // } else {
                        //   visibleTemperatureData = temperatureLens.where((data) => data.x.isAfter(minX) && data.x.isBefore(maxX)).toList();
                        // }
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
                      color: Colors.deepOrange,
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
                Text('Avg. BG：${avgBloodSugar.toStringAsFixed(2)}'),
                const Spacer(),
                Text('Avg. TEMP：${avgTemperature.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getTextList(
      bool chooseBloodSugar, List<int> displayBloodSugarTIR, List<int> displayTemperatureTIR, int length) {
    List<String> ranges =
        chooseBloodSugar ? ['>300', '200~300', '126~200', '90~126', '<90'] : ['>42', '40~42', '38~40', '36~38', '<36'];
    List<int> displayTIR = chooseBloodSugar ? displayBloodSugarTIR : displayTemperatureTIR;
    Color barColor = chooseBloodSugar ? Colors.deepOrange : Colors.blue;

    return List.generate(ranges.length, (i) {
      double percentage = length > 0 ? (displayTIR[i] / length) * 100 : 0;
      return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${ranges[i]}：',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxBarWidth = constraints.maxWidth * 0.8;
                  final tmpWidth = (maxBarWidth * percentage / 100).clamp(0.0, maxBarWidth);
                  return Row(
                    children: [
                      Container(
                        width: tmpWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${percentage.toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
