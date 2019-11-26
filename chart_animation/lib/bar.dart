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

  factory BarChart.makeBars(Size size, int iterNumber) {

    final List<List<double>> heightsData = [
      [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0],
      [20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0],
      [30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0],
      [40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0],
    ];

    if (iterNumber >= heightsData.length) {return null;}

    final ranks = selectRanks(heightsData[iterNumber], ColorPalette.primary.length);
    final barCount = ranks.length;
    final barDistance = size.width / (1 + barCount);
    const barWidthFraction = 0.75;
    final barWidth = barDistance * barWidthFraction;
    final starty = barDistance - barWidth / 2;

    final bars = List.generate(
      barCount,
          (barIndex) => Bar(
            ranks[barIndex],
            starty + barIndex * barDistance,
            barWidth,
            heightsData[iterNumber][barIndex],
            ColorPalette.primary[ranks[barIndex]],
      ),
    );
    return BarChart(bars);
  }

  static List<int> selectRanks(List<double> currHeights, int cap) {
    final ranks = <int>[0, 1, 2, 3, 4, 5, 6];
    return ranks;
  }
}

class BarChartTween extends Tween<BarChart> {
  BarChartTween(BarChart begin, BarChart end) : super(begin: begin, end: end) {
    final bMax = begin.bars.length;
    final eMax = end.bars.length;
    var b = 0;
    var e = 0;
    while (b + e < bMax + eMax) {
      if (b < bMax && (e == eMax || begin.bars[b] < end.bars[e])) {
        _tweens.add(BarTween(begin.bars[b], begin.bars[b].collapsed));
        b++;
      }
      else if (e < eMax && (b == bMax || end.bars[e] < begin.bars[b])) {
        _tweens.add(BarTween(end.bars[e].collapsed, end.bars[e]));
        e++;
      }
      else {
        _tweens.add(BarTween(begin.bars[b], end.bars[e]));
        b++;
        e++;
      }
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
  bool operator <(Bar other) => rank < other.rank;

  static Bar lerp(Bar begin, Bar end, double t) {
    assert(begin.rank == end.rank);
    return Bar(
      begin.rank,
      lerpDouble(begin.y, end.y, t),
      lerpDouble(begin.width, end.width, t),
      lerpDouble(begin.height, end.height, t),
      Color.lerp(begin.color, end.color, t),
    );
  }
}

class BarTween extends Tween<Bar> {
  BarTween(Bar begin, Bar end) : super(begin: begin, end: end) {
    assert(begin.rank == end.rank);
  }

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