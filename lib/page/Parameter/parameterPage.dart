import 'package:cesa100/page/Parameter/parameterList.dart';
import 'package:flutter/material.dart';

class ParameterPage extends StatefulWidget {
  const ParameterPage({super.key});

  @override
  State<ParameterPage> createState() => _ParameterPageState();
}

class _ParameterPageState extends State<ParameterPage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(title: Text('Setting Parameter'),centerTitle: true,),
        body: ParameterList(),
      ),
    );
  }
}
