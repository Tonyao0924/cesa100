import 'dart:async';
import 'dart:convert';
import 'package:cesa100/page/Home/Detail/addCommentPage.dart';
import 'package:flutter/scheduler.dart';
import 'package:syncfusion_flutter_core/core.dart';

import 'package:cesa100/commonComponents/GlobalVariables.dart';
import 'package:cesa100/page/Home/Detail/editTIRPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../commonComponents/chartData.dart';
import '../../../commonComponents/constants.dart';
import '../../../commonComponents/totalDialog.dart';
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
  late TrackballBehavior _trackballBehavior;
  List<dynamic>? futureData; //讀取資料
  List<dynamic>? futureTIRData; //讀取TIR資料
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
  late int firstBgNonZeroIndex; // 紀錄TIR血糖最靠左非0數值
  late int lastBgNonZeroIndex; // 紀錄TIR血糖最靠右非0數值
  late int firstTempNonZeroIndex; // 紀錄TIR溫度最靠左非0數值
  late int lastTempNonZeroIndex; // 紀錄TIR溫度最靠右非0數值
  int initCirculation = 3; // 圖表顯示幾小時內資料
  late RangeController _rangeController;
  int lastId = 0; // 儲存backend最後一筆資料id
  int lastBG = 0;
  double lastTEMP = 0.0;
  List<Map<String, dynamic>> markerPoints = [];
  DateTime? _verticalLineX;
  String image_path = '';
  double zoomF = 0.1;

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
      maximumZoomLevel: 1,
      enablePanning: true, // 左右滾動
      // enablePinching: true, // 手勢縮放圖表大小
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
      lineDashArray: <double>[3, 5],
      lineWidth: 2,
      lineType: CrosshairLineType.both,
      shouldAlwaysShow: true,
    );
    _trackballBehavior = TrackballBehavior(
      enable: true,
      // markerSettings: TrackballMarkerSettings(markerVisibility: TrackballVisibilityMode.visible),
      shouldAlwaysShow: true,
    );
  }

  // 畫出圖表
  Future<void> drawChart() async {
    futureData = await fetchData();
    futureTIRData = await fetchTIRData();
    bloodSugarTIR = [0, 0, 0, 0, 0];
    temperatureTIR = [0, 0, 0, 0, 0];
    temperatureData = [];
    bloodSugarData = [];
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
      break;
    }
    if (futureData!.isNotEmpty) {
      lastId = futureData!.last['id'];
      lastBG = futureData!.last['Current_A'];
      lastTEMP = futureData!.last['Temperature_C'].toDouble();
    }
    totalCurrent = [];
    totalTemperature = [];
    bloodSugarLens = [];
    temperatureLens = [];
    markerPoints = [];
    int markerId = 1; // 初始化 marker ID 從 1 開始
    for (var item in futureData!) {
      DateTime tmp = DateTime.parse(item['DateTime']);
      double current = item['Current_A'] is double ? item['Current_A'] : item['Current_A'].toDouble();
      double temperature = item['Temperature_C'] is double ? item['Temperature_C'] : item['Temperature_C'].toDouble();
      String? description = item['description']?.isNotEmpty ?? false ? item['description'] : null;
      String? imagePath = item['image_path']?.isNotEmpty ?? false ? item['image_path'] : null;
      totalCurrent.add(current);
      totalTemperature.add(temperature);
      putTIRData(current, temperature);
      bloodSugarLens.add(ChartData(tmp, current));
      temperatureLens.add(ChartData(tmp, temperature));
      dataCount++;

      if (description != null || imagePath != null) {
        Map<String, dynamic> markerPoint = {
          'id': markerId++, // 給每個 markerPoint 賦予唯一的 ID 並遞增
          'x': tmp,
          'y': 0,
          if (description != null) 'description': description,
          if (imagePath != null) 'image_path': imagePath,
        };
        markerPoints.add(markerPoint); // 加入到 markerPoints 列表中
      }
    }
    print(markerPoints);
    if (firstinit) {
      // DateTime firstTime = DateTime.parse(futureData![0]['DateTime']);
      DateTime lastTime = DateTime.parse(futureData![futureData!.length - 1]['DateTime']);
      // minX = firstTime;
      // maxX = lastTime;
      // minX = maxX!.subtract(Duration(hours: 3)); // 預設為最後一筆減去三小時
      final int durationHours = (initCirculation * 0.8).floor();
      final int durationMinutes = ((initCirculation * 0.8 - durationHours) * 60).round();

      final offset = Duration(hours: durationHours, minutes: durationMinutes);

      // 設置 minX 和 maxX，讓 lastTime 出現在 4/5 位置
      minX = lastTime.subtract(offset);
      maxX = lastTime.add(Duration(hours: initCirculation - durationHours, minutes: -durationMinutes));
      _rangeController = RangeController(
        start: minX,
        end: maxX,
      );
      firstinit = false;
      print(minX);
      print(maxX);
    }
    avgBloodSugar = totalCurrent.reduce((a, b) => a + b) / totalCurrent.length;
    avgTemperature = totalTemperature.reduce((a, b) => a + b) / totalTemperature.length;
    displayBloodSugarTIR = bloodSugarTIR;
    displayTemperatureTIR = temperatureTIR;
    setState(() {});
  }

  // 放資料到TIR陣列當中
  void putTIRData(double current, double temperature) {
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
    if (temperature <= temperatureData[0]) {
      temperatureTIR[0]++;
    } else if (temperature <= temperatureData[1]) {
      temperatureTIR[1]++;
    } else if (temperature <= temperatureData[2]) {
      temperatureTIR[2]++;
    } else if (temperature <= temperatureData[3]) {
      temperatureTIR[3]++;
    } else {
      temperatureTIR[4]++;
    }
  }

  // 解析資料
  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('${GlobalVariables.serverIP}sensorData'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  // 拿取TIR Ranges的間隔值
  Future<List<dynamic>> fetchTIRData() async {
    final response = await http.get(Uri.parse('${GlobalVariables.serverIP}ranges'));
    if (response.statusCode == 200) {
      // print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load');
    }
  }

  // 變換顯示狀態
  void _toggleChartState() {
    setState(() {
      _chartState = (_chartState + 1) % 3;
      displayBloodSugarTIR = bloodSugarTIR;
      displayTemperatureTIR = temperatureTIR;
    });
  }

  void circulationLoop() {
    // print('-----------------');
    // print(minX);
    // print(maxX);
    print('_verticalLineX $_verticalLineX');
    setState(() {
      if (initCirculation != 24) {
        initCirculation *= 2;
      } else {
        initCirculation = 3;
      }

      final int frontDurationHours = (initCirculation * 0.2).floor();
      final int frontDurationMinutes = ((initCirculation * 0.2 - frontDurationHours) * 60).round();

      final frontOffset = Duration(hours: frontDurationHours, minutes: frontDurationMinutes);

      // 設置 minX 為垂直線前 1/5，maxX 為垂直線後 4/5
      maxX = _verticalLineX!.add(frontOffset);
      minX = maxX!.subtract(Duration(hours: initCirculation));
      print('circulationLoop $minX $maxX $frontOffset');
      _rangeController.start = minX;
      _rangeController.end = maxX;

      // 當_zoomPanBehavior被修改才能改變他的平移範圍 這邊先讓maximumZoomLevel被修改而改變他的平移量
      _zoomPanBehavior = ZoomPanBehavior(
        selectionRectColor: Colors.grey,
        zoomMode: ZoomMode.x,
        maximumZoomLevel: initCirculation.toDouble(),
        enablePanning: true, // 左右滾動
      );
      _setVerticalLine();
    });
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();

    // 當資料還沒讀到得時候 做的事件
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 陰影顏色和透明度
                    spreadRadius: 2, // 陰影擴散半徑
                    blurRadius: 2, // 陰影模糊半徑
                    offset: Offset(2, 2), // 陰影偏移量 (水平, 垂直)
                  ),
                ],
              ),
              margin: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                vertical: 10,
              ),
              padding: EdgeInsets.symmetric(vertical: _chartState == 0 ? height * 0.008 : 0),
              child: Row(
                mainAxisAlignment:
                    _chartState == 1 || _chartState == 2 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                children: [
                  if (_chartState == 0 || _chartState == 1)
                    Expanded(
                      // 直接使用 Expanded
                      child: FittedBox(
                        // FittedBox 包住整個 Row
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${(widget.rowData.bloodSugar).toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: _chartState == 1 ? 80 : 70,
                                      color: Color(0xff808080),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_chartState == 0)
                                          SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: Image.asset(
                                              'assets/home/arrow_-90angle.png',
                                              fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                        if (_chartState == 1)
                                          const Text(
                                            'mg/dl',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        if (_chartState == 0)
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: const Text(
                                              'mg/dl',
                                              style: TextStyle(
                                                fontSize: 10,
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
                            if (_chartState == 1)
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset(
                                  'assets/home/arrow_-90angle.png',
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (_chartState == 0 || _chartState == 2)
                    Expanded(
                      // 直接使用 Expanded
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${(widget.rowData.temperature).toStringAsFixed(1)}',
                                    style: TextStyle(
                                      fontSize: _chartState == 2 ? 80 : 70,
                                      color: Color(0xff808080),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  WidgetSpan(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_chartState == 0)
                                          SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: Image.asset(
                                              'assets/home/arrow_45angle.png',
                                              fit: BoxFit.scaleDown,
                                            ),
                                          ),
                                        if (_chartState == 2)
                                          const Text(
                                            '℃',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        if (_chartState == 0)
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: const Text(
                                              '℃',
                                              style: TextStyle(
                                                fontSize: 10,
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
                            if (_chartState == 2)
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.asset(
                                  'assets/home/arrow_45angle.png',
                                  fit: BoxFit.scaleDown,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              )),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: width * 0.02,
                // vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 陰影顏色和透明度
                    spreadRadius: 2, // 陰影擴散半徑
                    blurRadius: 2, // 陰影模糊半徑
                    offset: Offset(2, 2), // 陰影偏移量 (水平, 垂直)
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.only(bottom: height * 0.03, top: 40),
                      child: GestureDetector(
                        onTap: () {
                          _toggleChartState();
                        },
                        child: SfCartesianChart(
                          zoomPanBehavior: _zoomPanBehavior,
                          // tooltipBehavior: _tooltipBehavior,
                          // crosshairBehavior: _crosshairBehavior,
                          // trackballBehavior: _trackballBehavior,
                          plotAreaBorderWidth: 4, //外框線粗度
                          plotAreaBorderColor: Colors.black12,
                          onActualRangeChanged: _onActualRangeChanged,
                          annotations: <CartesianChartAnnotation>[
                            CartesianChartAnnotation(
                              widget: Container(
                                width: 2, // 線條寬度
                                height: height * 0.5, // 垂直高度
                                color: Colors.black, // 線條顏色
                              ),
                              coordinateUnit: CoordinateUnit.percentage, // 使用相對於畫布的座標系
                              x: '80%',
                              y: '50%',
                              region: AnnotationRegion.plotArea, // 限定在繪圖區域內
                            ),
                            CartesianChartAnnotation(
                              widget: (image_path == null || image_path.isEmpty)
                                  ? SizedBox.shrink() // 不顯示任何內容
                                  : GestureDetector(
                                      onTap: () async {
                                        // 尋找與 `_verticalLineX` 日期和分鐘相同的資料點
                                        var matchingData;
                                        for (var data in futureData!) {
                                          DateTime dataTime = DateTime.parse(data['DateTime']);
                                          if (dataTime.year == _verticalLineX!.year &&
                                              dataTime.month == _verticalLineX!.month &&
                                              dataTime.day == _verticalLineX!.day &&
                                              dataTime.hour == _verticalLineX!.hour &&
                                              dataTime.minute == _verticalLineX!.minute) {
                                            matchingData = data;
                                            break;
                                          }
                                        }

                                        // 如果找到匹配的數據點，則傳遞其資訊到 `AddCommentPage`
                                        if (matchingData != null) {
                                          final result = await Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation, secondaryAnimation) => AddCommentPage(
                                                lastId: matchingData['id'],
                                                lastBG: matchingData['Current_A'],
                                                lastTEMP: matchingData['Temperature_C'].toDouble(),
                                                lastTime: matchingData['DateTime'],
                                                description: matchingData['description'] ?? '',
                                                imagePath: matchingData['image_path'] ?? '',
                                                markerPoints: markerPoints ?? [],
                                              ),
                                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                const begin = Offset(1.0, 0.0);
                                                const end = Offset.zero;
                                                const curve = Curves.ease;
                                                var tween =
                                                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                                return SlideTransition(
                                                  position: animation.drive(tween),
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                          print('回傳的結果:$result');
                                          if (result == true) {
                                            showToast(context, '註釋已新增');
                                            drawChart();
                                            _setVerticalLine();
                                          }
                                        } else {
                                          showToast(context, '找不到數據點');
                                        }
                                      },
                                      child: (image_path == ' ')
                                          ? Image.asset(
                                              'assets/home/image.png', // 預設圖片路徑
                                              width: 60, // 圖片寬度
                                              height: 60, // 圖片高度
                                        color: Colors.black12,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              image_path,
                                              width: 80, // 圖片寬度
                                              height: 80, // 圖片高度
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                              coordinateUnit: CoordinateUnit.percentage,
                              x: '25%', // 右上角的位置
                              y: '15%', // 右上角的位置
                              region: AnnotationRegion.chart,
                            ),
                            ...markerPoints.map((point) {
                              return CartesianChartAnnotation(
                                region: AnnotationRegion.plotArea,
                                widget: const Icon(
                                  Icons.arrow_drop_up,
                                  size: 40,
                                  color: Colors.black45,
                                ),
                                coordinateUnit: CoordinateUnit.point,
                                x: point['x'], // 對應每個 marker 的 X 軸座標
                                y: point['y'], // 對應每個 marker 的 Y 軸座標
                              );
                            }).toList(),
                          ],
                          primaryXAxis: DateTimeAxis(
                            name: 'primaryXAxis',
                            axisLine: const AxisLine(color: Colors.transparent),
                            // title: const AxisTitle(text: 'Time'),
                            rangePadding: ChartRangePadding.additional,
                            // rangePadding: ChartRangePadding.round,
                            // initialVisibleMinimum: _rangeController.start,
                            // initialVisibleMaximum: _rangeController.end,
                            // initialZoomFactor: zoomF,
                            // enableAutoIntervalOnZooming: false,
                            minimum: DateTime(1900),
                            maximum: DateTime(2100),
                            rangeController: _rangeController,
                            majorGridLines: MajorGridLines(width: 0, color: Colors.black12), // 主分個格寬度
                            minorGridLines: MinorGridLines(width: 0, color: Colors.black12), // 次分隔線粗度
                            majorTickLines: MajorTickLines(width: 0), // 隱藏主要刻度線
                            minorTickLines: MinorTickLines(width: 0), // 隱藏次要刻度線
                            intervalType: DateTimeIntervalType.hours, // 確保每小時顯示一次標籤
                            interval: initCirculation / 3, // 每1個單位顯示一次標籤
                            dateFormat: DateFormat('HH:mm'),
                            // initialZoomPosition: 0.5,
                            axisLabelFormatter: (AxisLabelRenderDetails details) {
                              final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(details.value.toInt());

                              // 判斷是否為00:00
                              if (dateTime.hour == 0 && dateTime.minute == 0) {
                                return ChartAxisLabel(
                                    DateFormat('MM/dd').format(dateTime), TextStyle(color: Colors.black));
                              } else {
                                return ChartAxisLabel(
                                    DateFormat('HH:mm').format(dateTime), TextStyle(color: Colors.black));
                              }
                            },
                          ),
                          primaryYAxis: NumericAxis(
                            axisLine: const AxisLine(color: Colors.transparent),
                            interval: 40,
                            minimum: 0,
                            maximum: 280,
                            labelStyle: TextStyle(
                              color: _chartState == 0 || _chartState == 1 ? Colors.deepOrange : Colors.transparent,
                            ),
                            majorGridLines: MajorGridLines(
                              width: 1,
                              dashArray: [5, 5], // 設置虛線樣式
                              color: Colors.black12,
                            ),
                            // majorGridLines: MajorGridLines(width: 0, color: Colors.transparent), // 主分隔線粗度
                            minorGridLines: MinorGridLines(width: 1, color: Colors.black12), // 次分隔線粗度
                            majorTickLines: MajorTickLines(width: 0), // 隱藏主要刻度線
                            minorTickLines: MinorTickLines(width: 0), // 隱藏次要刻度線
                            numberFormat: NumberFormat('##0'),
                          ),
                          axes: <ChartAxis>[
                            NumericAxis(
                              axisLine: const AxisLine(color: Colors.transparent),
                              name: 'secondaryYAxis',
                              opposedPosition: true,
                              interval: 5,
                              minimum: 15,
                              maximum: 50,
                              // title: AxisTitle(
                              //   text: '℃',
                              //   textStyle: TextStyle(
                              //     color: _chartState == 0 || _chartState == 2 ? Colors.blue : Colors.transparent,
                              //   ),
                              // ),
                              labelStyle: TextStyle(
                                color: _chartState == 0 || _chartState == 2 ? Colors.blue : Colors.transparent,
                              ),
                              majorGridLines: MajorGridLines(
                                width: 1,
                                dashArray: [5, 5], // 設置虛線樣式
                                color: Colors.black12,
                              ),
                              // majorGridLines: MajorGridLines(width: 0, color: Colors.black12), // 主分個格寬度
                              minorGridLines: MinorGridLines(width: 0, color: Colors.black12), // 次分隔線粗度
                              majorTickLines: MajorTickLines(width: 0), // 隱藏主要刻度線
                              minorTickLines: MinorTickLines(width: 0), // 隱藏次要刻度線
                              numberFormat: NumberFormat('##0'),
                            ),
                          ],
                          series: <CartesianSeries>[
                            if (_chartState == 0 || _chartState == 1)
                              FastLineSeries<ChartData, DateTime>(
                                color: Colors.deepOrangeAccent,
                                dataSource: bloodSugarLens,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                width: 2, // 橘色值粗度
                                animationDuration: 0,
                              ),
                            if (_chartState == 0 || _chartState == 2)
                              FastLineSeries<ChartData, DateTime>(
                                color: Colors.blue,
                                dataSource: temperatureLens,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y,
                                yAxisName: 'secondaryYAxis',
                                name: '℃',
                                width: 2, // 藍色值粗度
                                animationDuration: 0,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    right: 10,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image(
                                image: AssetImage('assets/home/bloodsugar.png'),
                                fit: BoxFit.scaleDown,
                                width: 20,
                                height: 20,
                                color: _chartState != 2 ? Colors.deepOrange : Colors.transparent,
                              ),
                              Text(
                                'mg/dl',
                                style: TextStyle(
                                  color: _chartState != 2 ? Colors.deepOrange : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.resolveWith(
                                    (states) {
                                      return states.contains(MaterialState.pressed) ? iconHoverColor : iconColor;
                                    },
                                  ),
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                ),
                                onPressed: () {
                                  circulationLoop();
                                },
                                child: Text.rich(
                                  WidgetSpan(
                                    child: ImageIcon(
                                      AssetImage("assets/home/${initCirculation}h.png"),
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                                  // 尋找與 `_verticalLineX` 日期和分鐘相同的資料點
                                  var matchingData;
                                  for (var data in futureData!) {
                                    DateTime dataTime = DateTime.parse(data['DateTime']);
                                    if (dataTime.year == _verticalLineX!.year &&
                                        dataTime.month == _verticalLineX!.month &&
                                        dataTime.day == _verticalLineX!.day &&
                                        dataTime.hour == _verticalLineX!.hour &&
                                        dataTime.minute == _verticalLineX!.minute) {
                                      matchingData = data;
                                      break;
                                    }
                                  }

                                  // 如果找到匹配的數據點，則傳遞其資訊到 `AddCommentPage`
                                  if (matchingData != null) {
                                    final result = await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => AddCommentPage(
                                          lastId: matchingData['id'],
                                          lastBG: matchingData['Current_A'],
                                          lastTEMP: matchingData['Temperature_C'].toDouble(),
                                          lastTime: matchingData['DateTime'],
                                          description: matchingData['description'] ?? '',
                                          imagePath: matchingData['image_path'] ?? '',
                                          markerPoints: markerPoints ?? [],
                                        ),
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
                                    print('回傳的結果:$result');
                                    if (result == true) {
                                      showToast(context, '註釋已新增');
                                      await drawChart();
                                      _setVerticalLine();
                                    }
                                  } else {
                                    showToast(context, '找不到數據點');
                                  }
                                },
                                child: Text.rich(
                                  WidgetSpan(
                                      child: Icon(
                                    Icons.add_outlined,
                                    size: 30,
                                  )),
                                ),
                              ),
                              Column(
                                children: [
                                  Image(
                                    image: AssetImage('assets/home/temperature.png'),
                                    fit: BoxFit.scaleDown,
                                    width: 20,
                                    height: 20,
                                    color: _chartState != 1 ? Colors.blue : Colors.transparent,
                                  ),
                                  Text(
                                    '℃',
                                    style: TextStyle(
                                      color: _chartState != 1 ? Colors.blue : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
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
                            'Avg.：${avgBloodSugar.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: _chartState != 2 ? Colors.deepOrangeAccent : Colors.transparent,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Avg.：${avgTemperature.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: _chartState != 1 ? Colors.blue : Colors.transparent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 80,
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.02,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // 陰影顏色和透明度
                  spreadRadius: 2, // 陰影擴散半徑
                  blurRadius: 2, // 陰影模糊半徑
                  offset: Offset(2, 2), // 陰影偏移量 (水平, 垂直)
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () async {
                    var displayBloodSugarTIR2 = displayBloodSugarTIR;
                    var displayTemperatureTIR2 = displayTemperatureTIR;
                    var bloodSugarData2 = bloodSugarData;
                    var temperatureData2 = temperatureData;

                    var resultTIR = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => EditTIRPage(
                          displayBloodSugarTIR: displayBloodSugarTIR2,
                          displayTemperatureTIR: displayTemperatureTIR2,
                          totalCurrent: totalCurrent,
                          totalTemperature: totalTemperature,
                          dataCount: dataCount,
                          bloodSugarData: bloodSugarData2,
                          temperatureData: temperatureData2,
                        ),
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
                    if (resultTIR == null) {
                      print('no value');
                    } else {
                      setState(() {
                        displayBloodSugarTIR = resultTIR.sublist(0, 5);
                        displayTemperatureTIR = resultTIR.sublist(5, 10);
                      });
                      futureTIRData = await fetchTIRData();
                      for (var item in futureTIRData!) {
                        temperatureData[0] = item['temperature_1'].toDouble();
                        temperatureData[1] = item['temperature_2'].toDouble();
                        temperatureData[2] = item['temperature_3'].toDouble();
                        temperatureData[3] = item['temperature_4'].toDouble();

                        bloodSugarData[0] = item['current_1'].toDouble();
                        bloodSugarData[1] = item['current_2'].toDouble();
                        bloodSugarData[2] = item['current_3'].toDouble();
                        bloodSugarData[3] = item['current_4'].toDouble();
                        break;
                      }
                    }
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
              ],
            ),
          ),
          SizedBox(height: height * 0.02),
        ],
      ),
    );
  }

  // 繪製TIR顯示
  List<Widget> _getTextList(List<int> displayBloodSugarTIR, List<int> displayTemperatureTIR, int length) {
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
          width: MediaQuery.of(context).size.width * 0.85,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    'assets/home/bloodsugar.png',
                    fit: BoxFit.scaleDown,
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
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
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
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: Image.asset(
                    'assets/home/temperature.png',
                    fit: BoxFit.scaleDown,
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

  // 判斷直線
  void _setVerticalLine() {
    if (_verticalLineX != null && markerPoints.isNotEmpty) {
      DateTime? closestPointInDirection;
      int closestDifferenceInDirection = initCirculation;

      // 先按照滑動方向查找
      for (var point in markerPoints) {
        DateTime markerPointX = point['x'];
        int difference = (_verticalLineX!.difference(markerPointX).inMinutes).abs();

        if (_isRight) {
          // 滑動方向為右，尋找 _verticalLineX 右邊且距離最近的標記點
          if (markerPointX.isAfter(_verticalLineX!) && difference <= initCirculation * 2) {
            if (difference < closestDifferenceInDirection) {
              closestPointInDirection = markerPointX;
              closestDifferenceInDirection = difference;
            }
          }
        } else {
          // 滑動方向為左，尋找 _verticalLineX 左邊且距離最近的標記點
          if (markerPointX.isBefore(_verticalLineX!) && difference <= initCirculation * 2) {
            if (difference < closestDifferenceInDirection) {
              closestPointInDirection = markerPointX;
              closestDifferenceInDirection = difference;
            }
          }
        }
      }

      DateTime? finalPoint = closestPointInDirection;

      // 如果滑動方向找不到符合條件的點，則在所有標記點中尋找距離最近的點
      if (finalPoint == null) {
        DateTime? closestPointOverall;
        int closestDifferenceOverall = initCirculation;

        for (var point in markerPoints) {
          DateTime markerPointX = point['x'];
          int difference = (_verticalLineX!.difference(markerPointX).inMinutes).abs();

          // 找到距離最近的點
          if (difference < closestDifferenceOverall && difference <= initCirculation) {
            closestPointOverall = markerPointX;
            closestDifferenceOverall = difference;
          }
        }

        finalPoint = closestPointOverall;
      }

      if (finalPoint != null) {
        // 找到符合條件的標記點後更新
        setState(() {
          _verticalLineX = finalPoint;

          // 更新 image_path
          String? newImagePath = markerPoints.firstWhere(
                (point) => point['x'] == finalPoint,
            orElse: () => {'image_path': ''},
          )['image_path'];

          image_path = (newImagePath != null && newImagePath.isNotEmpty) ? newImagePath : ' ';

          // 計算前 1/5 和後 4/5 的範圍
          final int frontDurationHours = (initCirculation * 0.2).floor();
          final int frontDurationMinutes = ((initCirculation * 0.2 - frontDurationHours) * 60).round();
          final frontOffset = Duration(hours: frontDurationHours, minutes: frontDurationMinutes);

          maxX = _verticalLineX!.add(frontOffset);
          minX = maxX!.subtract(Duration(hours: initCirculation));

          _rangeController.start = minX;
          _rangeController.end = maxX;
        });
      } else {
        // 若沒有找到符合條件的標記點，清空 image_path
        image_path = '';
      }
    }

    // 重置 _verticalLineSetOnce
    Timer(const Duration(milliseconds: 300), () {
      _verticalLineSetOnce = false;
    });
  }

  bool _verticalLineSetOnce = false; // 新增一個布林變數
  bool _isRight = false; // 滑動方向
  double _previousData = 0; //記錄上一個點位，用來判斷_isRight這個變數

  void _onActualRangeChanged(ActualRangeChangedArgs args) {
    if (args.axis!.name == 'primaryXAxis') {
      final double visibleMin = _rangeController.start.millisecondsSinceEpoch.toDouble();
      final double visibleMax = _rangeController.end.millisecondsSinceEpoch.toDouble();
      final double tmpMin = args.visibleMin.toDouble();

      final DateTime positionAt80Percent = DateTime.fromMillisecondsSinceEpoch(
        (visibleMin + (visibleMax - visibleMin) * 4 / 5).toInt(),
      );

      if ((tmpMin - _previousData).abs() > 1) { //要大於1是因為避免手機判斷的誤差點
        if (tmpMin > _previousData) {
          _isRight = true;
        } else {
          _isRight = false;
        }
      }

      _previousData = tmpMin;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _verticalLineX = DateTime(
            positionAt80Percent.year,
            positionAt80Percent.month,
            positionAt80Percent.day,
            positionAt80Percent.hour,
            positionAt80Percent.minute,
          );
        });
      });
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (_isRight) {
        print('最後是往右');
      } else {
        print('最後是往左');
      }
      if (args.visibleMin != 0) {
        print('---一開始的資料$minX  $maxX');
        setState(() {
          minX = _rangeController.start;
          maxX = _rangeController.end;
          print('---一修改的資料${_rangeController.start}  ${_rangeController.end}');
          // print(maxX);

          print(maxX.difference(minX));

          // 更新圖表數據
          if (futureData != null) {
            _updateChartData();
          }

          if (!_verticalLineSetOnce) {
            _setVerticalLine();
            _verticalLineSetOnce = true;
          }
        });
      }
    });
  }

  void _updateChartData() {
    totalCurrent = [];
    totalTemperature = [];
    bloodSugarTIR = [0, 0, 0, 0, 0];
    temperatureTIR = [0, 0, 0, 0, 0];
    dataCount = 0;
    for (var item in futureData!) {
      DateTime itemDateTime = DateTime.parse(item['DateTime']);
      if (itemDateTime.isAfter(minX) && itemDateTime.isBefore(maxX)) {
        double current = item['Current_A'] is double ? item['Current_A'] : item['Current_A'].toDouble();
        double temperature = item['Temperature_C'] is double ? item['Temperature_C'] : item['Temperature_C'].toDouble();
        totalCurrent.add(current);
        totalTemperature.add(temperature);
        putTIRData(current, temperature);
        dataCount++;
      }
    }
    avgBloodSugar = totalCurrent.isNotEmpty ? totalCurrent.reduce((a, b) => a + b) / totalCurrent.length : 0.0;
    avgTemperature =
        totalTemperature.isNotEmpty ? totalTemperature.reduce((a, b) => a + b) / totalTemperature.length : 0.0;
    displayTemperatureTIR = temperatureTIR;
    displayBloodSugarTIR = bloodSugarTIR;
  }
}
