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
  List<dynamic>? futureData;
  List<ChartData> bloodSugarLens = [];
  List<ChartData> temperatureLens = [];
  List<int> bloodSugarTIR = [0, 0, 0, 0, 0];
  List<int> temperatureTIR = [0, 0, 0, 0, 0];
  int DataLens = 0;
  bool chooseBloodSugar = true;
  double avgBloodSugar = 0.0;
  double avgTemperature = 0.0;

  @override
  void initState() {
    super.initState();
    drawChart();
    bloodSugarLens.clear();
    temperatureLens.clear();
    _zoomPanBehavior = ZoomPanBehavior(
      // enableSelectionZooming: true,
      selectionRectBorderColor: Colors.red,
      selectionRectBorderWidth: 1,
      selectionRectColor: Colors.grey,
      zoomMode: ZoomMode.x,
      enablePanning: true,
      enablePinching: true,
      // maximumZoomLevel: 2.0, // 调整此值以设置最小缩放级别
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
      tooltipSettings: InteractiveTooltip(enable: true, color: Colors.red),
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
    for (var item in futureData!) {
      DateTime tmp = DateTime.parse(item['DateTime']);
      double current = item['Current_A'] is double ? item['Current_A'] : item['Current_A'].toDouble();
      double temperature = item['Temperature_C'] is double ? item['Temperature_C'] : item['Temperature_C'].toDouble();
      totalCurrent.add(current);
      totalTemperature.add(temperature);
      putTIRData(current, temperature);
      bloodSugarLens.add(ChartData(tmp, current));
      temperatureLens.add(ChartData(tmp, temperature));
    }
    avgBloodSugar = totalCurrent.reduce((a, b) => a + b) / totalCurrent.length;
    avgTemperature = totalTemperature.reduce((a, b) => a + b) / totalTemperature.length;
    setState(() {});
  }

  void putTIRData(double current, double temperature) {
    DataLens++;
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

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    if (_tooltipBehavior == null && _trackballBehavior == null && _crosshairBehavior == null || futureData == null) {
      return Scaffold(
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
                        width: 30,
                        height: 30,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.number}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Expanded(
                //   child: Row(
                //     children: [
                //       Image(
                //         image: AssetImage('assets/home/bloodsugar.png'),
                //         fit: BoxFit.scaleDown,
                //         width: 25,
                //         height: 25,
                //       ),
                //       FittedBox(
                //         fit: BoxFit.scaleDown,
                //         child: Text(
                //           '${widget.rowData.bloodSugar} mg/dl',
                //           style: TextStyle(
                //             fontSize: 14,
                //             color: Colors.black,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Expanded(
                //   child: Row(
                //     children: [
                //       Image(
                //         image: AssetImage('assets/home/temperature.png'),
                //         fit: BoxFit.scaleDown,
                //         width: 25,
                //         height: 25,
                //       ),
                //       FittedBox(
                //         fit: BoxFit.scaleDown,
                //         child: Text(
                //           '${widget.rowData.temperature} ℃',
                //           style: TextStyle(
                //             fontSize: 14,
                //             color: Colors.black,
                //           ),
                //         ),
                //       )
                //     ],
                //   ),
                // ),
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
                      side: BorderSide(width: 1, color: Colors.black),
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
                      side: BorderSide(width: 1, color: Colors.black),
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
                  children: _getTextList(chooseBloodSugar, bloodSugarTIR, temperatureTIR, futureData!.length),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child:Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image(
                        image: AssetImage('assets/home/bloodsugar.png'),
                        fit: BoxFit.scaleDown,
                        width: 25,
                        height: 25,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.bloodSugar} mg/dl',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image(
                        image: AssetImage('assets/home/temperature.png'),
                        fit: BoxFit.scaleDown,
                        width: 25,
                        height: 25,
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${widget.rowData.temperature} ℃',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: SfCartesianChart(
                zoomPanBehavior: _zoomPanBehavior,
                tooltipBehavior: _tooltipBehavior,
                trackballBehavior: _trackballBehavior,
                crosshairBehavior: _crosshairBehavior,
                primaryXAxis: const DateTimeAxis(
                  // intervalType: DateTimeIntervalType.minutes,
                  title: AxisTitle(text: 'Time'),
                  rangePadding: ChartRangePadding.round,
                  autoScrollingDelta: 1000,
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
                      color: Colors.deepOrange,
                    ),
                  ),
                  labelStyle: TextStyle(color: Colors.deepOrange),
                ),
                axes: <ChartAxis>[
                  NumericAxis(
                    name: 'secondaryYAxis',
                    opposedPosition: true,
                    interval: 5,
                    // interval: secondaryYAxisInterval,
                    // minimum: secondaryYAxisMin,
                    // maximum: secondaryYAxisMax,
                    title: AxisTitle(
                      text: '℃',
                      textStyle: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                ],
                series: <CartesianSeries>[
                  LineSeries<ChartData, DateTime>(
                    color: Colors.deepOrange,
                    dataSource: bloodSugarLens,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    // markerSettings: MarkerSettings(
                    //   isVisible: true,
                    //   shape: DataMarkerType.circle,
                    //   color: Colors.deepOrange,
                    //   borderWidth: 2,
                    //   borderColor: Colors.white,
                    // ),
                  ),
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
            padding: EdgeInsets.symmetric(horizontal: 20),
            margin: EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                Text('Avg. BG：${avgBloodSugar.toStringAsFixed(2)}'),
                Spacer(),
                Text('Avg. TEMP：${avgTemperature.toStringAsFixed(2)}'),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getTextList(bool chooseBloodSugar, List<int> bloodSugarTIR, List<int> temperatureTIR, int length) {
    List<String> bloodSugarRanges = ['>300', '200~300', '126~200', '90~126', '<90'];
    List<String> temperatureRanges = ['>42', '40~42', '38~40', '36~38', '<36'];
    List<Widget> textWidgets = [];

    if (chooseBloodSugar) {
      for (int i = 0; i < bloodSugarRanges.length; i++) {
        double percentage = (bloodSugarTIR[i] / length) * 100;
        textWidgets.add(
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${bloodSugarRanges[i]}：',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.transparent,
                            color: Colors.blue,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      for (int i = 0; i < temperatureRanges.length; i++) {
        double percentage = (temperatureTIR[i] / length) * 100;
        textWidgets.add(
          Text(
            '${temperatureRanges[i]}：${percentage.toStringAsFixed(2)}%',
            style: TextStyle(fontSize: 16),
          ),
        );
      }
    }

    return textWidgets;
  }
}
