# extended_path [![Pub](https://img.shields.io/pub/v/extended_path.svg)](https://pub.dartlang.org/packages/extended_path)

This library encapsulates the `PathExtended` object which serves as a extension to the parent [Path](https://docs.flutter.io/flutter/dart-ui/Path-class.html) class of Flutter. Internally a sampled representation of the Path is stored and updated, allowing to manipulate the Path object in powerful ways.

:construction: **This library is still at early-stage development and might be subject to breaking API changes!!!** :construction:

## Getting Started

```dart
    Path p = Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 2.0));
    PathExtended pp = PathExtended(p)
      ..applyPathEffect(DashPathEffect([10,2], dashOffset: -1))
      ..addPath(circle(0,30.0),Offset.zero);
```
