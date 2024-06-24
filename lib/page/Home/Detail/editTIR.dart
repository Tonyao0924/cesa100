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
                                child: GestureDetector(
                                  onTap: () async {
                                    int index = (i == widget.bloodSugarData.length) ? i - 1 : i;
                                    final tmp = await _showPicker(context, widget.bloodSugarData[index].toInt());
                                    setState(() {
                                      if (tmp > widget.bloodSugarData[index]) {
                                        print('bigger');
                                        widget.bloodSugarData[index] = tmp.toDouble();
                                        int previousIndex = index - 1;
                                        while (previousIndex >= 0 &&
                                            widget.bloodSugarData[previousIndex] <=
                                                widget.bloodSugarData[previousIndex + 1]) {
                                          widget.bloodSugarData[previousIndex] =
                                              widget.bloodSugarData[previousIndex + 1] + 1;
                                          previousIndex--;
                                        }
                                      } else if (tmp < widget.bloodSugarData[index]) {
                                        print('smaller');
                                        widget.bloodSugarData[index] = tmp.toDouble();
                                        int nextIndex = index + 1;
                                        while (nextIndex < widget.bloodSugarData.length &&
                                            widget.bloodSugarData[nextIndex - 1] <= widget.bloodSugarData[nextIndex]) {
                                          widget.bloodSugarData[nextIndex] = widget.bloodSugarData[nextIndex - 1] - 1;
                                          nextIndex++;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    (i == widget.bloodSugarData.length)
                                        ? '<${widget.bloodSugarData.last.toStringAsFixed(0)} : '
                                        : '>=${widget.bloodSugarData[i].toStringAsFixed(0)} : ',
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
                                child: GestureDetector(
                                  onTap: () async {
                                    int index = (i == widget.temperatureData.length) ? i - 1 : i;

                                    final tmp = await _showTemperaturePicker(context, widget.temperatureData[index]);
                                    setState(() {
                                      if (tmp > widget.temperatureData[index]) {
                                        widget.temperatureData[index] = tmp;
                                        int previousIndex = index - 1;
                                        while (previousIndex >= 0 && widget.temperatureData[previousIndex] <= widget.temperatureData[previousIndex + 1]) {
                                          widget.temperatureData[previousIndex] = widget.temperatureData[previousIndex + 1] + 0.1;
                                          previousIndex--;
                                        }
                                      } else if (tmp < widget.temperatureData[index]) {
                                        widget.temperatureData[index] = tmp;
                                        int nextIndex = index + 1;
                                        while (nextIndex < widget.temperatureData.length && widget.temperatureData[nextIndex - 1] >= widget.temperatureData[nextIndex]) {
                                          widget.temperatureData[nextIndex] = widget.temperatureData[nextIndex - 1] - 0.1;
                                          nextIndex++;
                                        }
                                        // 如果 i 是最后一个元素，且更新了它，就设置 i = i - 1
                                        if (index == widget.temperatureData.length - 1) {
                                          i = index - 1;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    i == widget.temperatureData.length
                                        ? '<${widget.temperatureData.last.toStringAsFixed(1)} : '
                                        : '>=${widget.temperatureData[i].toStringAsFixed(1)} : ',
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
