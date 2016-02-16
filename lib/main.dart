import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(title: "Flutter Demo", routes: <String, RouteBuilder>{
    '/': (RouteArguments args) => new FlutterDemo()
  }));
}

const int _kRows = 2;
const int _kColumns = 2;

class FlutterDemo extends StatefulComponent {
  @override
  State createState() => new FlutterDemoState();
}

class FlutterDemoState extends State {
  int counter = 0;
  List<List<SpinnyNathan>> spinnyNathans;

  @override
  void initState() {
    super.initState();
    spinnyNathans = new List.generate(
        _kRows, (_) => new List.generate(_kColumns, (_) => new SpinnyNathan()));
    final math.Random random = new math.Random();
      new Timer.periodic(const Duration(milliseconds:100), (_){
        int row = random.nextInt(_kRows);
        int column = random.nextInt(_kColumns);
      (spinnyNathans[row][column].key as GlobalKey).currentState.fall();

      });
}


  @override
  Widget build(BuildContext context) => new DefaultAssetBundle(
      bundle: rootBundle,
      child: new Center(
          child: new Row(
              children: new List.generate(
                  _kRows,
                  (int rowIndex) => new Column(
                      children: new List.generate(
                          _kColumns,
                          (int columnIndex) =>
                              spinnyNathans[rowIndex][columnIndex]))))));
}

class SpinnyNathan extends StatefulComponent {
  SpinnyNathan() : super(key: new GlobalKey());
  SpinnyNathanState createState() => new SpinnyNathanState();
}

class SpinnyNathanState extends State<SpinnyNathan> {
  final AnimationController controller =
      new AnimationController(duration: const Duration(seconds: 1));
  CurvedAnimation curve;
  SpinnyNathanState() {
    curve =
        new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.forward();
    controller.addStatusListener((AnimationStatus status) {
      print("controller $hashCode: $controller");
      if (status == AnimationStatus.dismissed) {
        controller.forward();
      } else {
      }
    });
  }

  void fall() {
    controller.reverse();
  }

  @override
  Widget build(_) => new AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) => new Opacity(
          opacity: curve.value,
          child: new Transform(
              transform: new Matrix4.identity()
                  .translate(0.0, 600.0 * (1.0 - curve.value)),
              child: new Transform(
                  alignment: new FractionalOffset(0.5, 0.5),
                  transform: new Matrix4.identity()
                      .rotateZ(math.PI * 2.0 * curve.value)
                      .scale(curve.value),
                  child: child))),
      child: new GestureDetector(onTap: () {
        controller.reverse();
      },
          child: new Container(
              width: 100.0,
              height: 100.0,
              child: new AssetImage(name: 'packages/lolwat/res/Nathan.png'),
              decoration:
                  new BoxDecoration(backgroundColor: new Color(0xFFFFFF00)))));
}
