import 'package:flutter/material.dart';

import 'drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;
  final double strokeWidth;
  Sketcher({this.lines = const [], this.strokeWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; j++) {
        if(lines[i].path[j] !=null && lines[i].path[j+1] != null){
          paint.color = lines[i].color;
          paint.strokeWidth=lines[i].width;
          canvas.drawLine(lines[i].path[j], lines[i].path[j+1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
