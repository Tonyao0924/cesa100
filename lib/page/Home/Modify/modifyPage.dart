import 'package:cesa100/page/Home/Modify/modifyItem.dart';
import 'package:flutter/material.dart';

import '../../../commonComponents/constants.dart';
import '../Home/petlist.dart';

class ModifyPage extends StatefulWidget {
  final petRowData rowData;
  const ModifyPage({Key? key, required this.rowData}) : super(key: key);

  @override
  State<ModifyPage> createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Modify',
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
      body: ModifyItem(rowData: widget.rowData),
    );
  }
}
