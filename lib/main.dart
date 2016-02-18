import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui show window;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
      title: "Flutter Demo",
      routes: <String, RouteBuilder>{
        '/': (RouteArguments args) => new FlutterDemo()
      }));
}

class FlutterDemo extends StatefulComponent {
  @override
  State createState() => new FlutterDemoState();
}

class FlutterDemoState extends State {
  int _rows;
  int _columns;
  List<List<SpinnyNathan>> _spinnyNathans;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (ui.window.size == Size.zero) {
      return new Container();
    }
    if (_spinnyNathans == null || _spinnyNathans.isEmpty) {
      _rows = (ui.window.size.height / 100.0).floor();
      _columns = (ui.window.size.width / 100.0).floor();
      // Switch to immersive mode in case we're running on android.
      try {
        activity.setSystemUiVisibility(SystemUiVisibility.immersive);
      } catch (exception) {
        print("Failed to set immersive: $exception");
      }
      _spinnyNathans = new List.generate(
          _rows, (_) => new List.generate(_columns, (_) => new SpinnyNathan()));
      final math.Random random = new math.Random();
      new Timer.periodic(const Duration(milliseconds: 50), (_) {
        int row = random.nextInt(_rows);
        int column = random.nextInt(_columns);
        (_spinnyNathans[row][column].key as GlobalKey).currentState.fall();
      });
    }

    return new DefaultAssetBundle(
        bundle: rootBundle,
        child: new Center(
            child: new IntrinsicWidth(
                child: new Row(
                    children: new List.generate(
                        _columns,
                        (int columnIndex) => new IntrinsicHeight(
                            child: new Column(
                                children: new List.generate(
                                    _rows,
                                    (int rowIndex) => _spinnyNathans[rowIndex]
                                        [columnIndex]))))))));
  }
}

class SpinnyNathan extends StatefulComponent {
  SpinnyNathan() : super(key: new GlobalKey());
  SpinnyNathanState createState() => new SpinnyNathanState();
}

class SpinnyNathanState extends State<SpinnyNathan> {
  final AnimationController controller =
      new AnimationController(duration: const Duration(seconds: 1));
  CurvedAnimation curve;
  int _fallCount = 0;
  SpinnyNathanState() {
    curve =
        new CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.forward();
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        controller.forward();
      } else {}
    });
  }

  void fall() {
    if (controller.value > 0.0 &&
        controller.status != AnimationStatus.reverse) {
      controller.reverse();
      setState(() {
        _fallCount++;
      });
    }
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
        fall();
      },
          child: new ClipRRect(
              xRadius: 8.0,
              yRadius: 8.0,
              child: new Container(
                  width: 100.0,
                  height: 100.0,
                  child: new Stack(children: [
                    new AssetImage(name: 'packages/lolwat/res/Nathan.png'),
                    new Align(
                        alignment: new FractionalOffset(1.0, 1.0),
                        child: new Container(
                            padding: new EdgeDims.all(8.0),
                            decoration: new BoxDecoration(
                                backgroundColor: new Color(0x80000000),
                                borderRadius: 8.0),
                            child: new Text(_fallCount.toString(),
                                style: new TextStyle(
                                    color: new Color(0xFFEEEEEE),
                                    fontSize: 16.0))))
                  ]),
                  decoration: new BoxDecoration(
                      backgroundColor: new Color(0xFFFFFF00))))));
}
