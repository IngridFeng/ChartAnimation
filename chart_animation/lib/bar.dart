import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'color_palette.dart';

class BarChart {
  final List<Bar> bars;
  BarChart(this.bars);

  factory BarChart.empty(Size size) {
    return BarChart(<Bar>[]);
  }

  factory BarChart.makeBars(Size size, int iterNumber, List<double> currHeights) {
    final ranks = computeRanks(currHeights);
    final barCount = currHeights.length;
    final barDistance = size.width / (1 + barCount);
    const barWidthFraction = 0.75;
    final barWidth = barDistance * barWidthFraction;
    final starty = barDistance - barWidth / 2;

    final bars = List.generate(
      barCount,
          (i) => Bar(
            ranks[i],
            starty + ranks[i] * barDistance,
            barWidth,
            currHeights[i],
            ColorPalette.primary[i],
      ),
    );
    return BarChart(bars);
  }

  static List<int> computeRanks(List<double> currHeights) {
    final ranks = <int>[];
    for (final h1 in currHeights) {
      var rank = 0;
      for (final h2 in currHeights) {
        if (h1 > h2) rank++;
      }
      ranks.add(currHeights.length - rank - 1);
    }
    return ranks;
  }
}

class BarChartTween extends Tween<BarChart> {
  BarChartTween(BarChart begin, BarChart end) : super(begin: begin, end: end) {
    var i = 0;
    while (i < begin.bars.length) {
      _tweens.add(BarTween(begin.bars[i], end.bars[i]));
      i++;
    }
  }

  final _tweens = <BarTween>[];

  @override
  BarChart lerp(double t) => BarChart(
    List.generate(
        _tweens.length,
            (i) => _tweens[i].lerp(t)
    ),
  );
}

class Bar {
  Bar(this.rank, this.y, this.width, this.height, this.color);

  final int rank;
  final double y;
  final double width;
  final double height;
  final Color color;

  Bar get collapsed => Bar(rank, y, 0.0, 0.0, color);

  static Bar lerp(Bar begin, Bar end, double t) {
    return Bar(
      begin.rank,
      lerpDouble(begin.y, end.y, t),
      lerpDouble(begin.width, end.width, t),
      lerpDouble(begin.height, end.height, t),
      begin.color,
//      Color.lerp(begin.color, end.color, t),
    );
  }
}

class BarTween extends Tween<Bar> {
  BarTween(Bar begin, Bar end) : super(begin: begin, end: end);

  @override
  Bar lerp(double t) => Bar.lerp(begin, end, t);
}

class BarChartPainter extends CustomPainter {
  BarChartPainter(Animation <BarChart> animation)
      : animation = animation,
        super(repaint: animation);

  final Animation<BarChart> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final chart = animation.value;

    for (final bar in chart.bars) {
      paint.color = bar.color;
      canvas.drawRect(
        Rect.fromLTWH(0, bar.y, bar.height, bar.width),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter old) => false;
}