import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Home/petlist.dart';

class DetailItem extends StatefulWidget {
  final petRowData rowData;
  const DetailItem({Key? key, required this.rowData}) : super(key: key);

  @override
  State<DetailItem> createState() => _DetailItemState();
}

class _DetailItemState extends State<DetailItem> {
  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            Row(
              children: [
                SizedBox(width: width * 0.1),
                Image(
                  image: AssetImage(widget.rowData.src),
                  fit: BoxFit.scaleDown,
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: width * 0.1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.rowData.number}',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: width * 0.1),
                Image(
                  image: AssetImage('assets/home/bloodsugar.png'),
                  fit: BoxFit.scaleDown,
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: width * 0.1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.rowData.bloodSugar} mg/dl',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                SizedBox(width: width * 0.1),
                Image(
                  image: AssetImage('assets/home/temperature.png'),
                  fit: BoxFit.scaleDown,
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: width * 0.1),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${widget.rowData.temperature} ℃',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
