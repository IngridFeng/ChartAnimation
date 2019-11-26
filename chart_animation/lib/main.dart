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
  int counter;
  AnimationController animation;
  BarChartTween tween;

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  void initData() {
    setState(() {
      counter = 0;
      animation = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      tween = BarChartTween(
        BarChart.empty(size),
        BarChart.makeBars(size, counter),
      );
      animation.forward();
    });
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

  Padding buttonWrapper(IconData icon, Function action) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: FloatingActionButton(
        child: Icon(icon),
        onPressed: action,
      ),
    );
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
      floatingActionButton: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          buttonWrapper(Icons.file_upload, changeData),
          buttonWrapper(Icons.refresh, initData),
          buttonWrapper(Icons.arrow_forward, changeData),
        ]
      )
    );
  }
}
