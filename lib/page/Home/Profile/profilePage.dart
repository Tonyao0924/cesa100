import 'package:cesa100/page/Home/Home/homelist.dart';
import 'package:cesa100/page/Home/Profile/profilecontent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../commonComponents/constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Edit Profile',
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
              // 在这里添加按钮点击后的逻辑
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
      body: Column(
        children: [
          Expanded(
            child: ProfileContent(),
          ),
        ],
      ),
    );
  }
}
