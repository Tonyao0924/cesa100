import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 打開修改的視窗
Future<List<double>?> openEditBGTIRDialog(BuildContext context, List<double> bloodSugarData) async {
  List<double> rangeData = List<double>.from(bloodSugarData);
  return showCupertinoDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // 使用 StatefulBuilder 來讓數據更新
        builder: (context, setState) {
          return CupertinoAlertDialog(
            title: Text(
              'Target Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loop through bloodSugarData with index
                for (var i = 0; i < rangeData.length; i++)
                  Row(
                    children: [
                      Text('Range ${i + 1}：'),
                      CupertinoButton(
                        onPressed: () async {
                          print('第 ${i + 1} , 數據: ${rangeData[i]}');
                          int? selectedValue = await openBGPickerDialog(context, rangeData[i].toInt());
                          if (selectedValue != null) {
                            setState(() {
                              rangeData[i] = selectedValue.toDouble(); // 更新數據並觸發重繪
                              for (var j = i - 1; j >= 0; j--) {
                                if (rangeData[j] >= rangeData[j + 1]) {
                                  rangeData[j] = rangeData[j + 1] - 1; // Ensure previous value is less
                                }
                              }

                              // Adjust subsequent values
                              for (var j = i + 1; j < rangeData.length; j++) {
                                if (rangeData[j] <= rangeData[j - 1]) {
                                  rangeData[j] = rangeData[j - 1] + 1; // Ensure next value is greater
                                }
                              }
                            });
                          }
                        },
                        child: Text('${rangeData[i].toStringAsFixed(0)} '),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(null); // Cancel action
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(rangeData); // Confirm action
                },
                child: Text('確認'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<int?> openBGPickerDialog(BuildContext context, int initialValue) async {
  int selectedValue = initialValue;

  return await showCupertinoModalPopup<int>(
    context: context,
    builder: (context) {
      return Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialValue - 50),
                  itemExtent: 32.0, // Height of each item
                  onSelectedItemChanged: (int index) {
                    selectedValue = 50 + index; // Convert index to value (50 ~ 600)
                  },
                  children: List<Widget>.generate(551, (int index) {
                    return Center(
                      child: Text('${50 + index}'), // Display values from 50 to 600
                    );
                  }),
                ),
              ),
            ),
            CupertinoButton(
              child: Text('確認'),
              onPressed: () {
                Navigator.of(context).pop(selectedValue); // 返回選擇的數值
              },
            )
          ],
        ),
      );
    },
  );
}

// 打開修改溫度視窗
Future<List<double>?> openEditTEMPTIRDialog(BuildContext context, List<double> temperatureData) async {
  List<double> rangeData = List<double>.from(temperatureData);
  return showCupertinoDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // 使用 StatefulBuilder 來讓數據更新
        builder: (context, setState) {
          return CupertinoAlertDialog(
            title: Text(
              'Target Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loop through bloodSugarData with index
                for (var i = 0; i < rangeData.length; i++)
                  Row(
                    children: [
                      Text('Range ${i + 1}：'),
                      CupertinoButton(
                        onPressed: () async {
                          print('第 ${i + 1} , 數據: ${rangeData[i]}');
                          double? selectedValue = await openTEMPPickerDialog(context, rangeData[i]);
                          if (selectedValue != null) {
                            setState(() {
                              rangeData[i] = selectedValue; // 更新數據並觸發重繪
                              for (var j = i - 1; j >= 0; j--) {
                                if (rangeData[j] >= rangeData[j + 1]) {
                                  rangeData[j] = rangeData[j + 1] - 0.1; // Ensure previous value is less
                                }
                              }

                              // Adjust subsequent values
                              for (var j = i + 1; j < rangeData.length; j++) {
                                if (rangeData[j] <= rangeData[j - 1]) {
                                  rangeData[j] = rangeData[j - 1] + 0.1; // Ensure next value is greater
                                }
                              }
                            });
                          }
                        },
                        child: Text('${rangeData[i].toStringAsFixed(1)} '),
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(null); // Cancel action
                },
                child: Text('取消'),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(context).pop(rangeData); // Confirm action
                },
                child: Text('確認'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<double?> openTEMPPickerDialog(BuildContext context, double initialValue) async {
  double selectedValue = initialValue;

  return await showCupertinoModalPopup<double>(
    context: context,
    builder: (context) {
      return Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                    initialItem: ((initialValue - 15) * 10).toInt()), // Adjusted for new range
                itemExtent: 32.0, // Height of each item
                onSelectedItemChanged: (int index) {
                  selectedValue = 15 + index * 0.1; // Convert index to value (15.0 ~ 50.0)
                },
                children: List<Widget>.generate(351, (int index) { // 15.0 to 50.0 has 351 steps
                  return Center(
                    child: Text('${(15 + index * 0.1).toStringAsFixed(1)}'), // Display values with one decimal place
                  );
                }),
              ),
            ),
            CupertinoButton(
              child: Text('確認'),
              onPressed: () {
                Navigator.of(context).pop(selectedValue); // 返回選擇的數值
              },
            )
          ],
        ),
      );
    },
  );
}

