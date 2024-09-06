import 'package:flutter/cupertino.dart';

Future<String?> openEditTIRDialog(BuildContext context, List<double> bloodSugarData) async {
  return showCupertinoDialog(
    context: context,
    builder: (context) {
      return CupertinoAlertDialog(
        title: Text(
          'Target Range',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loop through bloodSugarData with index
            for (var i = 0; i < bloodSugarData.length; i++)
              Row(
                children: [
                  Text('Range${i+1}：'),
                  CupertinoButton(
                    onPressed: () {
                      print('第 $i 圈, 數據: ${bloodSugarData[i]}');
                    },
                    child: Text('${bloodSugarData[i].toStringAsFixed(1)} mg/dL'),
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
              Navigator.of(context).pop('confirm'); // Confirm action
            },
            child: Text('確認'),
          ),
        ],
      );
    },
  );
}
