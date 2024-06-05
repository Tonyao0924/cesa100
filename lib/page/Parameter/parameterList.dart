import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../commonComponents/GlobalVariables.dart';
import '../../commonComponents/TodoDB.dart';
import '../../commonComponents/constants.dart';

class ParameterList extends StatefulWidget {
  const ParameterList({super.key});

  @override
  State<ParameterList> createState() => _ParameterListState();
}

class _ParameterListState extends State<ParameterList> {
  TextEditingController _runningTime = TextEditingController();
  TextEditingController _quietTime = TextEditingController();
  TextEditingController _sampleInterval = TextEditingController();
  TextEditingController _potential = TextEditingController();
  final List<String> data = ['E-4', 'E-5', 'E-6'];
  late String _dropdownValue = data.first; // Initialize here with a default value

  @override
  void initState() {
    super.initState();
    cancelFunction();
  }

  bool cancelFunction() {
    bool isSettingsModified = false;

    // Initialize text controllers with values from GlobalVariables
    _runningTime = TextEditingController(text: GlobalVariables.runningTime.text);
    _quietTime = TextEditingController(text: GlobalVariables.quietTime.text);
    _sampleInterval = TextEditingController(text: GlobalVariables.sampleInterval.text);
    _dropdownValue = GlobalVariables.sensitivity.text.isNotEmpty ? GlobalVariables.sensitivity.text : data.first;
    _potential = TextEditingController(text: GlobalVariables.potential.text);

    bool runningTime = _runningTime.text != GlobalVariables.runningTime.text;
    bool quietTime = _quietTime.text != GlobalVariables.quietTime.text;
    bool sampleInterval = _sampleInterval.text != GlobalVariables.sampleInterval.text;
    bool sensitivity = _dropdownValue != GlobalVariables.sensitivity.text;
    bool potential = _potential != GlobalVariables.potential.text;

    isSettingsModified = runningTime || quietTime || sampleInterval || sensitivity || potential;

    return isSettingsModified;
  }

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
              ],
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              controller: _runningTime,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                labelText: 'Running Time(ms)',
                labelStyle: TextStyle(color: hintTextColor),
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
              ],
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              controller: _quietTime,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                labelText: 'Quiet Time(ms)',
                labelStyle: TextStyle(color: hintTextColor),
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
              ],
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 20),
              controller: _sampleInterval,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1),
                ),
                labelText: 'Sample Interval(mV)',
                labelStyle: TextStyle(color: hintTextColor),
              ),
            ),
          ),
          SizedBox(height: width * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Row(
              children: [
                Text(
                  'Sensitivity:',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: _dropdownValue,
                  items: data.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _dropdownValue = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.05),
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            width: width * 1,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                GlobalVariables.runningTime = _runningTime;
                GlobalVariables.quietTime = _quietTime;
                GlobalVariables.sampleInterval = _sampleInterval;
                GlobalVariables.sensitivity = TextEditingController(text: _dropdownValue);
                TodoDB.updateSetting(context);
              },
              child: Text(
                'Apply',
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
