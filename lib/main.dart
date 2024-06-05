import 'package:cesa100/page/Navigation/Introduction/introductionPage.dart';
import 'package:cesa100/page/tmpPage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'commonComponents/TodoDB.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TodoDB.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    requestBluetoothPermission();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Color(0xfff1f1f1),
        useMaterial3: true,
      ),
      home: IntroductionPage(),
      // home: TmpPage(),
    );
  }
  Future<void> requestBluetoothPermission() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ].request();
  }
}
