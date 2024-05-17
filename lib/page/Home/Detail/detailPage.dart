import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

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
        title: Text(
          'Detail',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
              // 松开手指时恢复图片原始大小
              setState(() {
                _scale = 1.0;
              });
            },
            onTap: (){
              // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            child: Transform.scale(
              scale: _scale,
              child: Image(
                image: AssetImage("assets/home/user.png"),
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                height: 30.0,
                width: 30.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
