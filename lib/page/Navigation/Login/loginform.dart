import 'package:cesa100/commonComponents/constants.dart';
import 'package:cesa100/page/Home/Home/homePage.dart';
import 'package:cesa100/page/Navigation/Register/registerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Loginform extends StatefulWidget {
  const Loginform({super.key});

  @override
  State<Loginform> createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  bool _isPasswordVisible = true;
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
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
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    return Colors.transparent;
                  },
                ),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              onPressed: () {},
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
              'Login',
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
                'Don’t have an account?',
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
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => RegisterPage(),
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
