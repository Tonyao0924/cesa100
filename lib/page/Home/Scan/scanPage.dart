import 'package:flutter/material.dart';
import 'package:flutter_ttc_ble/flutter_ttc_ble.dart';
import 'package:flutter_ttc_ble/scan_screen.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScanScreen(
        title: 'Scan CESA Device',
        onDeviceClick: (BuildContext context, BLEDevice device) {},
      ),
    );
  }
}
