import 'package:flutter/material.dart';

class Loginform extends StatefulWidget {
  const Loginform({super.key});

  @override
  State<Loginform> createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    return Container(
      child: Column(
        children: [
          SizedBox(
            width: width * 0.8,
            height: height * 0.06,
            child: TextField(
              style: const TextStyle(
                color: Colors.white,
              ),
              controller: _emailcontroller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.transparent, width: 1), // 框線透明
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.transparent, width: 1), // 點擊後框線透明
                ),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                hintText: 'Enter your email',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
