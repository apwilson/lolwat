import 'dart:math' as math;

import 'package:flutter/widgets.dart';

void main() {
  runApp(new Cats());
}

class Cat extends StatelessComponent {
  @override
  Widget build(BuildContext context) {
    return new ClipRect(
        child: new Container(
            width: 100.0,
            height: 100.0,
            child: new NetworkImage(
                //fit:ImageFit.cover,
                //alignment:const FractionalOffset(0.0,0.5),
                src: 'https://i.ytimg.com/vi/UIrEM_9qvZU/maxresdefault.jpg')));
  }
}

class CatMetadata {
  Cat cat;
  Offset offset;
  CatMetadata(this.cat, this.offset);
}

class Cats extends StatefulComponent {
  CatsState createState() => new CatsState();
}

class CatsState extends State<Cats> {
  math.Random random = new math.Random();
  List<CatMetadata> catMetadata = [
    new CatMetadata(new Cat(), new Offset(0.0, 0.0))
  ];

  Widget build(_) {
    List<Widget> stackChildren = catMetadata
        .map((CatMetadata c) => new Positioned(
            left: c.offset.dx,
            top: c.offset.dy,
            child: new GestureDetector(onTap: () {
              setState(() {
                CatMetadata newCatMetadata = new CatMetadata(
                    new Cat(),
                    new Offset(random.nextDouble() * 600.0,
                        random.nextDouble() * 600.0));
                catMetadata.add(newCatMetadata);
              });
            }, child: c.cat)))
        .toList();

    return new Stack(children: stackChildren);
  }
}
