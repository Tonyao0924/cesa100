import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ttc_ble/flutter_ttc_ble.dart';
import 'package:flutter_ttc_ble/scan_screen.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with BleCallback2{
  List<BLEDevice> _devices = [];
  late Timer timer;

  @override
  void initState() {
    super.initState();
    bleProxy.addBleCallback(this);
    timer = new Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    FlutterTtcBle.stopLeScan();
    bleProxy.removeBleCallback(this);
  }

  Future<void> startScan() async {
    _devices.clear();
    await FlutterTtcBle.startLeScan((resultDeviceInformation) async {
      if (resultDeviceInformation.name != null &&
          !_devices.any((device) => device.name == resultDeviceInformation.name)) {
        setState(() {
          _devices.add(resultDeviceInformation);
        });
      }
    });
  }


  void stopscan() {
    FlutterTtcBle.stopLeScan();
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Device'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      startScan();
                    },
                    child: Text(
                      'Search',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // stopscan();
                      print(_devices.length);
                    },
                    child: Text(
                      'Stop',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('count:${_devices.length}'),
                SizedBox(width: width * 0.05),
              ],
            ),
            Divider(),
            ...List.generate(
              _devices.length,
              (index) => Container(
                padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _devices[index]);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth, size: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_devices[index].name}",
                          ),
                          Text(
                            "${_devices[index].deviceId}",
                          ),
                          Text(
                            "${_devices[index].rssi}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
