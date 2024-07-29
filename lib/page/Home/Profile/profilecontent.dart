import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../commonComponents/constants.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  String _name = 'Edison';

  @override
  Widget build(BuildContext context) {
    int width = MediaQuery.of(context).size.width.toInt();
    int height = MediaQuery.of(context).size.height.toInt();
    double appBarTop = (MediaQuery.of(context).padding.top);
    return Container(
      child: Column(
        children: [
          Container(
            width: width * 1,
            height: height * 0.2,
            color: buttonColor,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  _showCustomModalBottomSheet(width, height);
                },
                child: Image(
                  image: const AssetImage("assets/home/user.png"),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  height: height * 0.1,
                  width: height * 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.05),
            width: width * 1,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: Colors.black45),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      splashFactory: NoSplash.splashFactory,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      minimumSize: Size(width * 1, 50),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      side: BorderSide.none,
                    ),
                    onPressed: () {},
                    child: Row(
                      children: [
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Name',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _name,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1, color: DividerColor),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                    width: width * 1,
                    height: 50,
                    child: const Row(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'test@gmail.com',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 0.05),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                splashFactory: NoSplash.splashFactory,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: Size(width * 1, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide.none,
              ),
              onPressed: () {},
              child: const Row(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Change Password',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                splashFactory: NoSplash.splashFactory,
                elevation: 0,
                shadowColor: Colors.transparent,
                minimumSize: Size(width * 1, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                side: BorderSide.none,
              ),
              onPressed: () {},
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.05),
        ],
      ),
    );
  }

  // 更改照片選單
  Future<void> _showCustomModalBottomSheet(int width, int height) async {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          height: 250,
          width: width * 1,
          child: Column(
            children: [
              Container(
                width: width * 0.1,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 10),
              const Expanded(
                child: Image(
                  image: AssetImage("assets/home/user.png"),
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(width * 1, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Image(
                      image: AssetImage('assets/home/gallery.png'),
                      fit: BoxFit.scaleDown,
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: width * 0.05),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Select from gallery',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(width * 1, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/home/camera.png'),
                      fit: BoxFit.scaleDown,
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: width * 0.05),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Photograph',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  splashFactory: NoSplash.splashFactory,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  minimumSize: Size(width * 1, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/home/delete.png'),
                      fit: BoxFit.scaleDown,
                      width: 30,
                      height: 30,
                      color: Colors.red,
                    ),
                    SizedBox(width: width * 0.05),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Remove current photo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
