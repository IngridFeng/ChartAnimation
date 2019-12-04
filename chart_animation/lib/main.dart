import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:chart_animation/sheets.dart';
import 'package:chart_animation/bar.dart';
import 'dart:math';

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
  _ChartPageState createState() => new _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin{
  static const size = const Size(400.0, 400.0);
  static const duration = 300;
  int counter;
  AnimationController animation;
  BarChartTween tween;
  var heightsData = [];
  final sheets = GoogleSheets();

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

  void buildHeightsData() {
    var random = new Random();
    for (var i = 0; i < 10; i++) {
      List<double> currHeights = [];
      for (var j = 0; j < 7; j++) {
        currHeights.add(random.nextDouble() * 400.0);
      }
      heightsData.add(currHeights);
    }
  }

  void initData() {
    heightsData = [];
    buildHeightsData();
    setState(() {
      counter = 0;
      animation = AnimationController(
        duration: const Duration(milliseconds: duration),
        vsync: this,
      );
      tween = BarChartTween(
        BarChart.empty(size),
        BarChart.makeBars(size, counter, heightsData[counter]),
      );
      animation.forward();
    });
  }

  void changeData() async {
    while (counter < heightsData.length) {
      displayData();
      await Future.delayed(const Duration(milliseconds: duration * 2));
    }
  }

  void displayData() {
    setState(() {
      tween = BarChartTween(
        tween.evaluate(animation),
        BarChart.makeBars(size, counter, heightsData[counter]),
      );
      animation.forward(from: 0.0);
      counter++;
    });
  }

  void readFromSheets() async {
    String spreadsheetId = "1QMNPq16ko-AjyQT14PIzwAmbTXSDUD_3tNatDlSK4Zk";
    String range = "A1:A2";
    await sheets.readData(spreadsheetId, range);
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
          buttonWrapper(Icons.add, readFromSheets),
          buttonWrapper(Icons.refresh, initData),
          buttonWrapper(Icons.arrow_forward, changeData),
        ]
      )
    );
  }
}
