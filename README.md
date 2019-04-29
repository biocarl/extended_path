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

## Design
The API design for the PathEffect classes is inspired by [PathEffect](https://developer.android.com/reference/android/graphics/PathEffect.html) for native Android but with some differences:
- A `PathEffect` is applied to each Path object and not to the Paint object
- Additionally a `PathModifier` is introduced. Contrary to the `PathEffect` the overall contour of the Path is changed. Internally a `PathModifier` manipulates the sampled representation directly while a `PathEffect` only changes the way how the sampling points are connected. This allows to combine a `PathModifier` with a `PathEffect`: For instance, a straight line can be transformed into a dashed sinus-curve. Soon a `PathExtendedBuilder` will be exposed which allows to set up a PathExtended object without rebuilding the internal structure every time.
- Any feedback on the overall API design is really appreciated!

## Current limitations
- Internal sampling rate for the path data is currently hardcoded. This might noticeable when sampling a big amount of path data (bad performance) and also for very small paths (edgy lines). For change the sampling rate use `setDelta`

## TODO
- `PathEffect`: How to determine optimal `_delta` value for sampling. Also consider defining `_delta` over amount of resulting sampling points (required for path morping). Your Path is discrete now: What happens when the Path is scaled, consider resampling dynamically.
- `PathDashPathEffect`: Rotate Path elements according to normal of current Offset (see [PathDashPathEffect.Style](https://developer.android.com/reference/android/graphics/PathDashPathEffect.Style.html))
- `PathDashPathEffect`: Implement `advance` field of [PathDashPathEffect](https://developer.android.com/reference/android/graphics/PathDashPathEffect.html) by setting inital offset to `-dashOffset`
- `DashPathEffect`: Double dash pattern when odd (for now blocked by assert)

## Milestones

- [x] PathEffect: [DashPathEffect](https://developer.android.com/reference/android/graphics/DashPathEffect.html)
- [ ] PathEffect: [DiscretePathEffect](https://developer.android.com/reference/android/graphics/DiscretePathEffect.html)
- [x] PathEffect: [PathDashPathEffect](https://developer.android.com/reference/android/graphics/PathDashPathEffect.html)
- [ ] PathModifier: sin-wave
- [ ] PathModifier: zick-zack
- [ ] PathModifier: smoothing/simplify
- [ ] *(static)* Lerp between two Paths/ Morphing
- [ ] `PathExtendedBuilder` for better performance

## Supported PathEffects
Here is increasingly growing list with all available parameters and their visual effects. The animation serves for illustration purposes only. For creating such animations I would like to refer to [drawing_animation](https://github.com/biocarl/drawing_animation), another package of mine.

| Effect            | Example                            |
| :---             |    :---:                       |
| `DashPathEffect` | <img src="https://github.com/biocarl/img/raw/master/extended_path/dashed_line.gif" width="600px">   |
| `PathDashPathEffect` | <img src="https://github.com/biocarl/img/raw/master/extended_path/path_dash_line.gif" width="600px">   |
