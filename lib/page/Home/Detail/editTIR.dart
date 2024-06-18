import 'package:flutter/material.dart';

class EditTIRPage extends StatefulWidget {
  const EditTIRPage({super.key});

  @override
  State<EditTIRPage> createState() => _EditTIRPageState();
}

class _EditTIRPageState extends State<EditTIRPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit TIR'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [],
            ),
          ),
          Expanded(
            child: Column(
              children: [],
            ),
          ),
        ],
      ),
    );
  }
}
