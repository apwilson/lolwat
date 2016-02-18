import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as ui show window;

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const double _kImageWidth = 200.0;
const double _kImageHeight = 200.0;
const double _kFallDistance = 600.0;
const double _kTextPadding = 8.0;
const double _kRoundedCornerRadius = 8.0;
const double _kTextFontSize = 16.0;
const Duration _kFallDuration = const Duration(milliseconds: 500);
const Duration _kAutoFallDuration = const Duration(milliseconds: 50);

void main() {
  Widget photo = new AssetImage(name: 'packages/lolwat/res/Nathan.png');
  runApp(new MaterialApp(
      title: "Falling Photos",
      routes: <String, RouteBuilder>{
        '/': (RouteArguments args) =>
            new FallingPhotos(child: photo, autoFall: true)
      }));
}

class FallingPhotos extends StatefulComponent {
  final Widget child;
  final bool autoFall;
  FallingPhotos({this.child, this.autoFall: false});
  @override
  State createState() => new FallingPhotosState();
}

class FallingPhotosState extends State {
  int _rows;
  int _columns;
  List<List<FallingPhoto>> _fallingPhotos;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    // Switch to immersive mode in case we're running on android.
    try {
      activity.setSystemUiVisibility(SystemUiVisibility.immersive);
    } catch (exception) {
      print("Failed to set immersive: $exception");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ui.window.size.height <= 0.0 || ui.window.size.width <= 0.0) {
      return new Container();
    }

    _rows = math.max(1, (ui.window.size.height / _kImageHeight).floor());
    _columns = math.max(1, (ui.window.size.width / _kImageWidth).floor());
    _fallingPhotos = new List.generate(
        _rows,
        (_) => new List.generate(
            _columns, (_) => new FallingPhoto(child: config.child)));
    final math.Random random = new math.Random();
    if (config.autoFall) {
      _timer?.cancel();
      _timer = new Timer.periodic(_kAutoFallDuration, (_) {
        int row = random.nextInt(_rows);
        int column = random.nextInt(_columns);
        (_fallingPhotos[row][column].key as GlobalKey).currentState.fall();
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
                                    (int rowIndex) => _fallingPhotos[rowIndex]
                                        [columnIndex]))))))));
  }
}

class FallingPhoto extends StatefulComponent {
  final Widget child;
  FallingPhoto({this.child}) : super(key: new GlobalKey());
  State createState() => new FallingPhotoState();
}

class FallingPhotoState extends State<FallingPhoto> {
  final AnimationController controller =
      new AnimationController(duration: _kFallDuration);
  CurvedAnimation curve;
  int _fallCount = 0;
  FallingPhotoState() {
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
                  .translate(0.0, _kFallDistance * (1.0 - curve.value)),
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
              xRadius: _kRoundedCornerRadius,
              yRadius: _kRoundedCornerRadius,
              child: new Container(
                  width: _kImageWidth,
                  height: _kImageHeight,
                  child: new Stack(children: [
                    config.child,
                    new Align(
                        alignment: new FractionalOffset(1.0, 1.0),
                        child: new Container(
                            padding: new EdgeDims.all(_kTextPadding),
                            decoration: new BoxDecoration(
                                backgroundColor: new Color(0x80000000),
                                borderRadius: _kRoundedCornerRadius),
                            child: new Text(_fallCount.toString(),
                                style: new TextStyle(
                                    color: new Color(0xFFEEEEEE),
                                    fontSize: _kTextFontSize))))
                  ]),
                  decoration: new BoxDecoration(
                      backgroundColor: new Color(0xFFFFFF00))))));
}
