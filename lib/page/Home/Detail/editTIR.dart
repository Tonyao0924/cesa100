import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    firstBgNonZeroIndex = widget.bloodSugarTIR.indexWhere((value) => value > 0);
    lastBgNonZeroIndex = widget.bloodSugarTIR.lastIndexWhere((value) => value > 0);
    firstTempNonZeroIndex = widget.temperatureTIR.indexWhere((value) => value > 0);
    lastTempNonZeroIndex = widget.temperatureTIR.lastIndexWhere((value) => value > 0);
  }

  double calculatePercentage(int value, int length) {
    return length > 0 ? (value / length) * 100 : 0;
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
              //todo modify the data
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
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
                                double percentage = calculatePercentage(widget.bloodSugarTIR[i], widget.dataCount);
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
                  widget.bloodSugarTIR.length,
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
                                child: Text(
                                  i == widget.bloodSugarData.length
                                      ? '<=${widget.bloodSugarData.last} : '
                                      : '>=${widget.bloodSugarData[i]} : ',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxBarWidth = constraints.maxWidth;
                                double percentage = calculatePercentage(widget.bloodSugarTIR[i], widget.dataCount);
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
                                double percentage = calculatePercentage(widget.temperatureTIR[i], widget.dataCount);
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
                  widget.temperatureTIR.length,
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
                                child: Text(
                                  i == widget.temperatureData.length
                                      ? '<=${widget.temperatureData.last} : '
                                      : '>=${widget.temperatureData[i]} : ',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 14,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double maxBarWidth = constraints.maxWidth;
                                double percentage = calculatePercentage(widget.temperatureTIR[i], widget.dataCount);
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
