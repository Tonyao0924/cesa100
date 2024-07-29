import 'package:cesa100/commonComponents/totalDialog.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'GlobalVariables.dart';

class TodoDB {
  static const String dbName = 'test1.db';

  // 設定頁面參數設定的值
  static const String createAppSettingTable = '''CREATE TABLE app_settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      runningTime INTEGER,
      quietTime INTEGER,
      sampleInterval INTEGER,
      sensitivity TEXT,
      potential INTEGER
    )''';

  // 初始化資料庫並獲取資料酷
  static Future<Database> initializeDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) async {
        await db.execute(createAppSettingTable);
        await db.rawInsert(
            'INSERT INTO app_settings(id, runningTime, quietTime, sampleInterval, sensitivity, potential) '
                'VALUES(1, 30000, 2000, 100, "E-4", 600)' // 修正的部分，將字符串值用引号引起来
        );
      },
      version: 1,
    );
  }

  //初始化資料庫
  static Future<void> initialize() async {
    final Database database = await initializeDatabase();
    List<Map<String, dynamic>> result = await database.rawQuery('SELECT * FROM app_settings LIMIT 1');
    if (result.isNotEmpty) {
      print('Database is not empty');
      GlobalVariables.runningTime.text = result.first['runningTime'].toString();
      GlobalVariables.quietTime.text = result.first['quietTime'].toString();
      GlobalVariables.sampleInterval.text = result.first['sampleInterval'].toString();
      GlobalVariables.sensitivity.text = result.first['sensitivity'].toString();
      GlobalVariables.potential.text = result.first['potential'].toString();
    } else {
      print('Database is empty');
    }
  }

  // 更新設定的Func
  static Future<void> updateSetting(BuildContext context) async {
    final Database database = await initializeDatabase();
    await database.update('app_settings', {
      'runningTime': GlobalVariables.runningTime.text,
      'quietTime': GlobalVariables.quietTime.text,
      'sampleInterval': GlobalVariables.sampleInterval.text,
      'sensitivity': GlobalVariables.sensitivity.text,
      'potential': GlobalVariables.potential.text
    });
    showToast(context, 'Your changes have been applied successfully.');
  }
}
