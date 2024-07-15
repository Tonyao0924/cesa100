import 'package:cesa100/page/Home/Detail/detailItem.dart';
import 'package:cesa100/page/Home/Home/petlist.dart';
import 'package:cesa100/page/Home/Modify/modifyPage.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  final petRowData rowData;
  const DetailPage({Key? key, required this.rowData}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double _scale = 1;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          children: [
            Image(
              image: AssetImage(widget.rowData.src),
              fit: BoxFit.scaleDown,
              width: 30,
              height: 30,
            ),
            Text(
              '${widget.rowData.number}',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTapDown: (details) {
              setState(() {
                _scale = 0.8;
              });
            },
            onTapUp: (details) {
              setState(() {
                _scale = 1.0;
              });
            },
            onTapCancel: () {
              setState(() {
                _scale = 1.0;
              });
            },
            onTap: (){
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => ModifyPage(rowData: widget.rowData),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Transform.scale(
              scale: _scale,
              child: Image(
                image: AssetImage("assets/home/gear.png"),
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                height: 30.0,
                width: 30.0,
              ),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: DetailItem(rowData: widget.rowData),
    );
  }
}
