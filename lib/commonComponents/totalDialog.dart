import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';




OverlayEntry? _currentOverlay;
Timer? _timer;

// 使用自己的toast
void showToast(BuildContext context, String message) {
  int height = MediaQuery.of(context).size.height.toInt();

  // 移除當前顯示的 Toast
  if (_currentOverlay != null) {
    _currentOverlay?.remove();
    _timer?.cancel();
  }

  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Card(
            color: Colors.black.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  // 顯示 Toast 一段時間後移除
  _timer = Timer(const Duration(seconds: 2), () {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
    }
    // 更新當前 OverlayEntry
    _currentOverlay = null;
  });
  // 更新當前 OverlayEntry
  _currentOverlay = overlayEntry;
}

// 顯示錯誤的訊息的視窗
Future<String?> errorDialog(BuildContext context, String msg) {
  final double screenWidth = MediaQuery.of(context).size.width;

  return showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text(
            '錯誤',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xff444444),
            ),
            textAlign: TextAlign.center,
          ),
          content: Center(
            child: Text(msg),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('確認'),
              isDestructiveAction: false,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      });
}