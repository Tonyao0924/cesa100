import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/page/Home/Home/homelist.dart';
import 'package:cesa100/page/Home/Profile/profilePage.dart';
import 'package:cesa100/page/Home/Scan/scanPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _scale = 1;
  double _scale2 = 1;

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: appBarTop, left: 10,right: 10),
              color: buttonColor,
              child: Row(
                children: [
                  Text(
                    'Hello, Edison',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
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
                          pageBuilder: (context, animation, secondaryAnimation) => ScanPage(),
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
                        image: AssetImage("assets/home/plus.png"),
                        color: Colors.black,
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        _scale2 = 0.8;
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        _scale2 = 1.0;
                      });
                    },
                    onTapCancel: () {
                      // 松开手指时恢复图片原始大小
                      setState(() {
                        _scale2 = 1.0;
                      });
                    },
                    onTap: (){
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => ProfilePage(),
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
                      scale: _scale2,
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
            ),
            Expanded(child: HomeList()),
            Container(
              width: width * 1,
              height: 80,
              decoration: const BoxDecoration(
                color: buttonColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
