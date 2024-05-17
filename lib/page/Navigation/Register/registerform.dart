import 'package:cesa100/page/Navigation/Login/loginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../commonComponents/constants.dart';
import '../../Home/Home/homePage.dart';

class Registerform extends StatefulWidget {
  const Registerform({super.key});

  @override
  State<Registerform> createState() => _RegisterformState();
}

class _RegisterformState extends State<Registerform> {
  bool _isPasswordVisible = true;
  TextEditingController _namecontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();
  TextEditingController _confirmpasswordcontroller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return Container(
      child: Column(
        children: [
          Spacer(),
          SizedBox(
            width: width * 0.8,
            height: height * 0.06,
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _namecontroller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 框線透明
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 點擊後框線透明
                ),
                hintText: 'Full Name',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: width * 0.8,
            height: height * 0.06,
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _emailcontroller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 框線透明
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 點擊後框線透明
                ),
                hintText: 'Email',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: width * 0.8,
            height: height * 0.06,
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _passwordcontroller,
              obscureText: _isPasswordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 框線透明
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 點擊後框線透明
                ),
                hintText: 'Password',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  style: IconButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
          Spacer(),
          SizedBox(
            width: width * 0.8,
            height: height * 0.06,
            child: TextField(
              style: const TextStyle(
                color: Colors.black,
              ),
              controller: _confirmpasswordcontroller,
              obscureText: _isPasswordVisible,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 框線透明
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: outLineBorder, width: 1), // 點擊後框線透明
                ),
                hintText: 'Confirm Password',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  style: IconButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
          ),
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
              minimumSize: Size(width * 0.8, height * 0.06),
              backgroundColor: buttonColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
                    (route) => route == null,
              );
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(
                  color: Colors.black12,
                  fontSize: 12,
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      return Colors.transparent;
                    },
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                        (route) => route == null,
                  );
                },
              ),
            ],
          ),
          Spacer(flex: 3),
        ],
      ),
    );
  }
}
