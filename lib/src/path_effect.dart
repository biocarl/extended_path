import 'dart:ui';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

/// Change sampling rate _delta. For internal use.
void setDelta(PathEffect pathEffect, double delta) {
  pathEffect._delta = delta;
}

/// Base class for any style applied on _raw
abstract class PathEffect {
  double get delta => _delta;
  double _delta = 0.1;

  /// This method iterates over sample points of each segment and paints to the canvas when a Path object is returned.
  ///
  /// Optionally null can be returned and the canvas is not manipulated for the corresponding sample point. This is for instance useful when introducing gaps between sampled points.
  ///
  /// After processing the last sample point of a segment [onSegmentFinished] is called.
  Path transform(Offset offset, Offset normal);

  /// Is called on last processed sample point of every segment. Useful for deciding what should happen when at end of each segment.
  ///
  /// When a Path object is returned it will be added to the overall path. Otherwise return null.
  ///
  /// Possible uses are for example resetting internal counters or adding a custom line ending to the segment.
  ///
  /// `isClosed` denotes if the current segment should be closed. Logic as storing last and first element has to be implemented by the subclasses.
  Path onSegmentFinished({bool isClosed = false}) {
    throw UnimplementedError();
    //Example for isClosed==true
    //Add Path element between lerp(Offset.start/end)
  }
}

/// Default [PathEffect], connects the raw points of the sampled Path with a polyline.
///
/// Ideally this PathEffect should not be visible. Required when _raw Offsets are manipulated (as PathModifier) but no explicit PathEffect is desired.
class ContinousLine extends PathEffect {
  List<Offset> _toPaint = List();

  @override
  Path transform(Offset offset, Offset normal) {
    _toPaint.add(offset);
    return null;
  }

  @override
  Path onSegmentFinished({bool isClosed = false}) {
    Path path;
    if (_toPaint.isNotEmpty) {
      path = Path()..addPolygon(_toPaint, isClosed);
      _toPaint.clear();
    }
    return path;
  }
}

/// Chop the path into lines of [segmentLength], randomly deviating from the original path by [deviationAngle].
///
/// Reasonable values for the  [deviationAngle] usually range from 0 to 45 degrees.
class DiscretePathEffect extends _DashPathEffect {
  DiscretePathEffect(int segmentLength, this.deviationAngle)
      : super([segmentLength, segmentLength]);

  /// Denotes the maximum angle of deviation for each segment
  final double deviationAngle;

  /// Denotes the previous already deviated Offset
  Offset _prevD;

  /// Denotes first Offset of segment
  Offset _first;

  @override
  Path transform(Offset offset, Offset normal) {
    Path path;
    //iterate to next Offset
    getNextPath(offset);
    if (this.end != null) {
      //dashed line without gaps
      Offset paintFrom, paintTo;
      path = Path();
      if (this._prevD == null) {
        paintFrom = this.start; //first offset
        this._first = this.start;
      } else {
        paintFrom = this._prevD;
      }

      //Deviate next end of line
      paintTo = _rotate(end, paintFrom,
          (((Random().nextInt(1000) + 1) % deviationAngle) / 360 * 2 * pi));
      path.moveTo(paintFrom.dx, paintFrom.dy);
      path.lineTo(paintTo.dx, paintTo.dy);
      this._prevD = paintTo;
    }
    return path;
  }

  Offset _rotate(Offset point, Offset pivot, double angle) {
    double s = sin(angle);
    double c = cos(angle);
    //to origin
    point -= pivot;
    // rotate
    double xr = point.dx * c - point.dy * s;
    double yr = point.dx * s + point.dy * c;
    // back to local
    return Offset(xr + pivot.dx, yr + pivot.dy);
  }

  @override
  Path onSegmentFinished({bool isClosed = false}) {
    // Connect them by a simple line
    Path path;
    if (isClosed && this._first != null) {
      path = Path();
      path.moveTo(this._prevD.dx, this._prevD.dy);
      path.lineTo(this._first.dx, this._first.dy);
    }
    this._first = null;
    return path;
  }
}

/// Transforms the stroke into a dashed representation.
class DashPathEffect extends _DashPathEffect {
  /// Constructs a DashPathEffect.
  ///
  /// [dashArray] should have an even number of elements. Optionally a [dashOffset] can be specified which defined an offset on the rendering of the associated dash array.
  DashPathEffect(List<int> dashArray, {int dashOffset})
      : super(dashArray, dashOffset);

  @override
  Path transform(Offset offset, Offset normal) {
    Path path;
    if (getNextPath(offset)) {
      path = Path()
        ..moveTo(this.start.dx, this.start.dy)
        ..lineTo(this.end.dx, this.end.dy);
    }
    return path;
  }
}

/// Similar to [DashPathEffect] but instead of a line the path object in [shape] is substituted for each dash.
class PathDashPathEffect extends _DashPathEffect {
  /// For every dash specified via [dashArray] a shape is stamped at the center of each dash. Appropriate size and orientation of the shape has to be provided.
  PathDashPathEffect(this.shape, List<int> dashArray) : super(dashArray);

  /// Defines the shape which is stamped at every dash.
  final Path shape;

  @override
  Path transform(Offset offset, Offset normal) {
    Path path;
    if (getNextPath(offset)) {
      path = Path()..addPath(shape, Offset.lerp(this.start, this.end, 0.5));
    }
    return path;
  }
}

/// Abstraction for Dashing a Path. Used for dashed lines or generic Path objects
abstract class _DashPathEffect extends PathEffect {
  _DashPathEffect(List<int> dashArray, [this.dashOffset]) {
    this._dashArray = dashArray.map((i) => (i / super.delta).round()).toList();
    assert(this._dashArray.every((dash) => dash > 0),
        "Length of alternating strokes and gaps has to be greater 0.");
    assert(this._dashArray.length % 2 == 0,
        "The number of elements in the dashArray has to be even.");
    createDashOffset();
  }

  List<int> _dashArray;
  int dashOffset;
  bool isDashOffset = false;
  bool draw = true; //denotes if gap - stroke

  //Denotes the relative Offset count for one dash (empty or not)
  int dashCircleIndex = 0;
  // _dashArray[dashArrayCycleIndex] denotes the current dash length (empty or not)
  int dashArrayCycleIndex = 0;

  /// Denotes the beginning offset of of dash element
  Offset start = Offset.zero;

  /// Denotes the terminating offset of of dash element
  Offset end = Offset.zero;

  /// Denotes the prev processed offset
  Offset _prev;

  @override
  Path onSegmentFinished({bool isClosed = false}) {
    draw = true;
    dashCircleIndex = 0;
    dashArrayCycleIndex = 0;
    createDashOffset();
    return null;
  }

  /// Iterate all counters till they reflect the provided dash-offset
  void createDashOffset() {
    if (dashOffset != null && dashOffset != 0) {
      int dashOffsetIndex = (this.dashOffset / super.delta).round();
      int sumDashPatternIndex = _dashArray.reduce((a, b) => a + b);
      //Works push (+)/pull(-) operations
      dashOffsetIndex %= sumDashPatternIndex;
      for (int i = 0; i < dashOffsetIndex; i++) iterateCounters();
      this.isDashOffset = true;
    }
  }

  /// Returns true if `start` and `end` Offsets of one non-empty dash element is available
  bool getNextPath(Offset offset) {
    //Get first and last offset for one dash (empty or not)
    if (dashCircleIndex == 0 || isDashOffset) {
      //end of prev dash cycle is start of next cycle
      if (this._prev != null) {
        this.start = this._prev;
        iterateCounters(); //we already started dash cycle one offset earlier so we have to update the counting state
      } else {
        this.start = offset; //case for first non-empty dash cycle
      }

      this.end = null;
      this.isDashOffset = false;
    }

    if (dashCircleIndex == _dashArray[dashArrayCycleIndex] - 1) {
      this.end = offset;
    }

    //Determines if gap or stroke dash
    this.draw = dashArrayCycleIndex % 2 == 0;
    iterateCounters();

    //end of prev cycle is start of next cycle
    if (this.end != null) {
      this._prev = offset;
    }
    return draw && (end != null);
  }

  void iterateCounters() {
    //Init next dash cycle of dash pattern
    if (dashCircleIndex == _dashArray[dashArrayCycleIndex] - 1) {
      dashCircleIndex = -1;
      dashArrayCycleIndex++;
      // dashCircleIndex--; //end of prev cycle is start of next cycle
    }

    //Init new dash pattern cycle
    if (dashArrayCycleIndex == _dashArray.length) {
      dashArrayCycleIndex = 0;
    }

    dashCircleIndex++;
  }
}
