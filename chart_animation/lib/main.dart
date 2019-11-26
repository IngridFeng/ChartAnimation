import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

import 'bar.dart';

void main() {
  runApp(MaterialApp(
    title: "Chart",
    theme: ThemeData(primarySwatch: Colors.pink),
    home: ChartPage(title: "Chart Home Page"),
  ));
}

class ChartPage extends StatefulWidget {
  ChartPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  ChartPageState createState() => ChartPageState();
}

class ChartPageState extends State<ChartPage> with TickerProviderStateMixin{
  static const size = const Size(400.0, 400.0);
  int counter = 0;
  AnimationController animation;
  BarChartTween tween;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    tween = BarChartTween(
      BarChart.empty(size),
      BarChart.makeBars(size, counter),
    );
    animation.forward();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  void changeData() {
    BarChart bars = BarChart.makeBars(size, counter);
    while (bars != null) {
      setState(() {
        tween = BarChartTween(tween.evaluate(animation), bars,);
        animation.forward(from: 0.0);
        counter++;
        bars = BarChart.makeBars(size, counter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            CustomPaint(size: size, painter: BarChartPainter(tween.animate(animation)),),
            Text('Count: $counter',),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: changeData,
      ),
    );
  }
}
