import 'package:flutter/material.dart';

class EditTIRPage extends StatefulWidget {
  const EditTIRPage({Key? key}) : super(key: key);

  @override
  State<EditTIRPage> createState() => _EditTIRPageState();
}

class _EditTIRPageState extends State<EditTIRPage> {
  List<double> data = [0, 0, 98, 2, 0]; // 目前的資料，以百分比表示
  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.red];
  List<String> labels = ["300", "200", "126", "90"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit TIR',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 8), // 調整文字與圖表之間的間距
              SizedBox(
                width: 80, // 控制圖表的寬度
                height: 300, // 控制圖表的高度
                child: CustomPaint(
                  painter: BarChartPainter(data, colors, labels),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<Color> colors;
  final List<String> labels;

  BarChartPainter(this.data, this.colors, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    double totalHeight = size.height;
    double totalWidth = size.width;
    double currentY = 0;
    double separatorHeight = 2; // 分隔線的高度
    double spacing = 1; // 每個區間之間的間距
    double labelWidth = 30; // 刻度文字的寬度
    double barWidth = totalWidth - labelWidth; // 值條的寬度

    for (int i = 0; i < data.length; i++) {
      double barHeight =
          data[i] * (totalHeight - spacing * (data.length - 1) - separatorHeight * (data.length - 1)) / 100;
      Paint barPaint = Paint()..color = colors[i];

      // 繪製值條
      canvas.drawRect(
        Rect.fromLTWH(labelWidth, currentY, barWidth, barHeight),
        barPaint,
      );

      currentY += barHeight;

      // 繪製分隔線和刻度文字
      if (i < data.length - 1) {
        currentY += spacing;
        Paint separatorPaint = Paint()..color = Colors.black;
        canvas.drawRect(
          Rect.fromLTWH(labelWidth, currentY, barWidth, separatorHeight),
          separatorPaint,
        );

        // 繪製刻度文字
        if (i < labels.length) {
          drawText(
            canvas,
            labels[i],
            Offset(0, currentY - separatorHeight / 2 - 12 / 2), // 12 是文字大小，調整文字的偏移量
            TextStyle(color: Colors.black, fontSize: 12),
          );
        }

        currentY += separatorHeight + spacing;
      }
    }
  }

  void drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final TextSpan span = TextSpan(text: text, style: style);
    final TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
