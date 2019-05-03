import 'dart:ui';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'path_effect.dart';
import 'path_modifier.dart';
import 'dart:math';

/// A extended [Path] object exposing several additional capabilities.
///
/// An [PathExtended] can be used as any other [Path] object. Internally a sampled representation of the Path is stored and updated allowing to manipulate the Path object quickly. Once all parameters are set the [PathExtended] object does not differ performance-wise from a [Path] object. During construction the internal representation has to be updated (and sometimes rebuilt) several times. For a large number of operations it is therefore suggested to utilize a [PathExtendedBuilder] which triggers a rebuilt only once upon creation.
///
/// Optionally the object can be intiialized with a `path` object which must not be empty.
class PathExtended extends Path {
  /// Internal Documentation
  ///
  /// [Design - data structures]
  /// Each ExtendedPath is representated in 3 forms
  /// 1) Path _root: All overwritten commands are delegated to this object allowing to create a mirror of the original Path object. Useful when resampling required (e.g. changing PathModifier effect)
  /// 2) List<Tangent> _raw: A sampled representation of _root, depends on a certain sampling rate _delta (created by _samplePath(_root)), segmented through _segmentInfos
  /// 3) this: Represents the final path object which is obtained by applying PathEffect/PathManipulation on the _raw represetation. If no effect is specified this == _root. (Created by _rebuildPath()). Default way to create the final path object is spanning a polyline over all _raw values in each sampled segment

  /// You can initialize a PathExtended object by optionally providing a [path] object.
  PathExtended([Path path]) : this._root = Path() {
    if (path != null && !_isEmpty(path)) {
      addPath(path, Offset.zero);
    }
    _setDelta(3);
  }

  //Datastructures
  final Path _root;
  final List<Tangent> _raw = [];
  List<_SegmentInfo> _segmentInfos = List();

  //Sampling related
  final double _baseDelta = 1.0;
  int _truncationFactor = 3;
  double _delta = 1.0;
  double _totalLength = 0;
  PathEffect _pathEffect;
  PathModifier _pathModifier;

  /// Set _delta over a multiple of _baseDelta value produces _delta= 1.0, 0.5, 0.125, 0.0625
  void _setDelta(int truncationFactor) {
    if (truncationFactor >= 0) {
      this._truncationFactor = truncationFactor;
      this._delta = _baseDelta / pow(2, _truncationFactor);
      _resampleRoot();
    }
  }

  /// Samples for a given Path a List<Offset> and appends it to _raw
  void _samplePath(Path path) {
    for (PathMetric pathSegment in path.computeMetrics()) {
      _totalLength += pathSegment.length;
      // performance: sampling factor is reduced for very large paths
      if (_truncationFactor > 0 && _totalLength > 10000 / _truncationFactor) {
        _setDelta(_truncationFactor - 1);
        return;
      }

      Path segment = pathSegment.extractPath(0, pathSegment.length);
      final PathMetric metric = segment.computeMetrics().first;
      for (double i = _delta; i <= metric.length + _delta; i += _delta) {
        // Offset currentOffset = metric.extractPath(i - _delta, i).getBounds().topLeft;
        Tangent tangent = metric.getTangentForOffset(i - _delta);
        //TODO this is for sure not performant - find a math way to do this
        tangent = Tangent(
            Offset(
                double.parse(
                    tangent.position.dx.toStringAsFixed(_truncationFactor)),
                double.parse(
                    tangent.position.dy.toStringAsFixed(_truncationFactor))),
            Offset.zero);

        //Here the PathModifier is applied
        if (this._pathModifier != null) {
          Offset modifiedOffset =
              this._pathModifier.transform(tangent.position, tangent.vector);
          tangent = Tangent(modifiedOffset, tangent.vector);
        }

        this._raw.add(tangent);
      }
      if (this._raw.isNotEmpty)
        _segmentInfos.add(_SegmentInfo(_raw.length, pathSegment.isClosed));
    }
  }

  /// Sample everything from scratch
  void _resampleRoot() {
    _raw.clear();
    _segmentInfos.clear();
    _totalLength = 0;
    _samplePath(this._root);
    _rebuildPath();
  }

  /// Resample last segment and subsitutes corresponding offsets in _raw
  void _resampleLastSegment() {
    if (_segmentInfos.length < 2) {
      // 0: no segment resampled yet or 1: only single segment
      _resampleRoot();
    } else {
      final PathMetric metric = this._root.computeMetrics().last;
      Path segment = metric.extractPath(0, metric.length);
      _raw.removeRange(
          _segmentInfos[_segmentInfos.length - 2].upperBound, _raw.length);
      _samplePath(segment);
    }
  }

  /// When providing a path effect other than [ContinousLine] the path of this instance will be rebuilt.
  void applyPathEffect(PathEffect pathEffect) {
    setDelta(pathEffect, this._delta);
    this._pathEffect = pathEffect;
    _rebuildPath();
  }

  /// Operates on sampled values
  void applyPathModifier(PathModifier pathModifier) {
    this._pathModifier = pathModifier;
    _resampleRoot();
  }

  /// Build whole Path from scratch
  void _rebuildPath() {
    if (_raw.isEmpty || (_pathEffect == null && _pathModifier == null)) {
      //Pass original path object to `this` - no need to rebuilt path
      super.reset();
      super.addPath(this._root, Offset.zero);
      return;
    }

    if (_pathEffect == null) {
      this._pathEffect = ContinousLine();
    }

    //Init current point
    Path path = Path();
    path.moveTo(_raw.first.position.dx, _raw.first.position.dy);
    this._pathEffect.onSegmentFinished();

    //Iterate over all sampled points for each segment
    int segmentIndex = 0;
    for (int i = 0; segmentIndex < _segmentInfos.length; i++) {
      //Closing old - starting new segment
      if (_segmentInfos[segmentIndex].upperBound == i) {
        _addPathOrNull(
            path,
            Offset.zero,
            this._pathEffect.onSegmentFinished(
                isClosed: _segmentInfos[segmentIndex].isClose));
        segmentIndex++;

        if (i != _raw.length) {
          path.moveTo(_raw[i].position.dx,
              _raw[i].position.dy); //current point of next segment
        } else {
          break; //last segment - no further processing
        }
      }

      //Process raw
      _addPathOrNull(path, Offset.zero,
          this._pathEffect.transform(_raw[i].position, _raw[i].vector));
    }

    // Set built path to `this`
    super.reset();
    super.addPath(path, Offset.zero);
  }

  void _addPathOrNull(Path target, Offset offset, Path source,
      {Float64List matrix4}) {
    if (source != null) {
      target.addPath(source, offset, matrix4: matrix4);
    }
  }

  @override
  void addPath(Path path, Offset offset, {Float64List matrix4}) {
    this._root.addPath(path, offset, matrix4: matrix4);
    path = path.shift(offset);
    if (matrix4 != null) {
      path = path.transform(matrix4);
    }
    _samplePath(path);
    _rebuildPath();
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    this._root.addArc(oval, startAngle, sweepAngle);
    _samplePath(Path()..addArc(oval, startAngle, sweepAngle));
    _rebuildPath();
  }

  @override
  void addOval(Rect oval) {
    this._root.addOval(oval);
    _samplePath(Path()..addOval(oval));
    _rebuildPath();
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    this._root.addPolygon(points, close);
    _samplePath(Path()..addPolygon(points, close));
    _rebuildPath();
  }

  @override
  void addRect(Rect rect) {
    this._root.addRect(rect);
    _samplePath(Path()..addRect(rect));
    _rebuildPath();
  }

  @override
  void addRRect(RRect rect) {
    this._root.addRRect(rect);
    _samplePath(Path()..addRRect(rect));
    _rebuildPath();
  }

  @override
  void close() {
    super.close();
    this._root.close();
    if (!_segmentInfos.last.isClose) {
      _segmentInfos.last.isClose = true;
      _resampleLastSegment();
      _rebuildPath();
    }
  }

  @override
  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    this._root.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void arcToPoint(Offset arcEnd,
      {Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    this._root.arcToPoint(arcEnd,
        radius: radius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    this._root.conicTo(x1, y1, x2, y2, w);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    this._root.cubicTo(x1, y1, x2, y2, x3, y3);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void lineTo(double x, double y) {
    this._root.lineTo(x, y);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    this._root.quadraticBezierTo(x1, y1, x2, y2);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void relativeArcToPoint(Offset arcEndDelta,
      {Radius radius = Radius.zero,
      double rotation = 0.0,
      bool largeArc = false,
      bool clockwise = true}) {
    this._root.relativeArcToPoint(arcEndDelta,
        radius: radius,
        rotation: rotation,
        largeArc: largeArc,
        clockwise: clockwise);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    this._root.relativeConicTo(x1, y1, x2, y2, w);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    this._root.relativeCubicTo(x1, y1, x2, y2, x3, y3);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void relativeLineTo(double dx, double dy) {
    this._root.relativeLineTo(dx, dy);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    this._root.relativeQuadraticBezierTo(x1, y1, x2, y2);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void extendWithPath(Path path, Offset offset, {Float64List matrix4}) {
    this._root.extendWithPath(path, offset, matrix4: matrix4);
    _resampleLastSegment();
    _rebuildPath();
  }

  @override
  void moveTo(double x, double y) {
    this._root.moveTo(x, y);
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    this._root.relativeMoveTo(dx, dy);
    _resampleLastSegment();
    _rebuildPath();
  }

  /// No need to overwrite since buildPath is stored in super
// Rect getBounds()
// bool contains(Offset point)
// PathMetrics computeMetrics({bool forceClosed: false})

  @override
  void reset() {
    super.reset();
    _raw.clear();
    _segmentInfos.clear();
    _totalLength = 0;
    _root.reset();
  }

  @override
  Path shift(Offset offset) {
    return super.shift(offset);
  }

  @override
  Path transform(Float64List matrix4) {
    return super.transform(matrix4);
  }
}

class _SegmentInfo {
  _SegmentInfo(this.upperBound, this.isClose);

  /// Indicates the index of the last sampled point of this segment in _raw (exclusive (!) bound) => first index of next segment
  final int upperBound;
  bool isClose;
}

/// Some utility functions
bool _isEmpty(Path path) {
  Rect rect = path.getBounds();
  return rect.width + rect.height == 0.0;
}

/// Compare two Path objects based on their sampled Offsets. Is `byPath` false the _raw Offsets are compared directly. Useful for unit testing PathModifier.
bool comparePaths(Path a, Path b, {bool byPath = false}) {
  if (byPath) {
    a = PathExtended(a)..applyPathEffect(ContinousLine());
    b = PathExtended(b)..applyPathEffect(ContinousLine());
  } else {
    //If comparing PathExtended with Path
    if (a is! PathExtended) {
      a = PathExtended(a)..applyPathEffect(ContinousLine());
    }
    if (b is! PathExtended) {
      b = PathExtended(b)..applyPathEffect(ContinousLine());
    }
  }

  return IterableEquality<Offset>().equals(
      (a as PathExtended)._raw.map((a) => a.position).toList(),
      (b as PathExtended)._raw.map((a) => a.position).toList());
}
