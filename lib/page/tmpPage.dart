import 'package:flutter/material.dart';

class TimeInRange extends StatelessWidget {
  final double high;
  final double target;
  final double low;
  final double veryLow;
  final double barWidth;

  TimeInRange({
    required this.high,
    required this.target,
    required this.low,
    required this.veryLow,
    this.barWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Time in Ranges (TIR)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 20),
        Container(
          height: 300,
          child: Stack(
            children: [
              CustomPaint(
                size: Size(barWidth, 300),
                painter: BarPainter(high, target, low, veryLow),
              ),
              Positioned(
                top: 0,
                left: barWidth + 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('很高'),
                    Text('高'),
                    Text('目標'),
                    Text('低'),
                    Text('很低'),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${high.toStringAsFixed(0)}% TAR'),
                    Text('${target.toStringAsFixed(0)}% TIR'),
                    Text('${low.toStringAsFixed(0)}% TBR'),
                    Text('${veryLow.toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BarPainter extends CustomPainter {
  final double high;
  final double target;
  final double low;
  final double veryLow;

  BarPainter(this.high, this.target, this.low, this.veryLow);

  @override
  void paint(Canvas canvas, Size size) {
    double totalHeight = size.height;
    double highHeight = totalHeight * (high / 100);
    double targetHeight = totalHeight * (target / 100);
    double lowHeight = totalHeight * (low / 100);
    double veryLowHeight = totalHeight * (veryLow / 100);

    Paint highPaint = Paint()..color = Colors.red;
    Paint targetPaint = Paint()..color = Colors.green;
    Paint lowPaint = Paint()..color = Colors.yellow;
    Paint veryLowPaint = Paint()..color = Colors.red[700]!;

    canvas.drawRect(
      Rect.fromLTWH(0, totalHeight - highHeight, size.width, highHeight),
      highPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, totalHeight - highHeight - targetHeight, size.width, targetHeight),
      targetPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, totalHeight - highHeight - targetHeight - lowHeight, size.width, lowHeight),
      lowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, totalHeight - highHeight - targetHeight - lowHeight - veryLowHeight, size.width, veryLowHeight),
      veryLowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}