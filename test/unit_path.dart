import 'package:test/test.dart';
import 'package:extended_path/extended_path.dart';
import 'package:extended_path/src/path.dart';
import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

import 'utils.dart';

void main() {
  test('Sampling accuracy - ContinousLine acts as identity function', () {
    Path p1;
    PathExtended pe1;
    //Path without curvature doesn't loose resolution if it 1/pow(2,n) with n = |N
    p1 = Path();
    p1.lineTo(1.125, 0); //FOR now is fixed at _truncationFactor == 3
    pe1 = PathExtended(p1)..applyPathEffect(ContinousLine());
    expect(
        p1.computeMetrics().first.length == pe1.computeMetrics().first.length,
        true);
  });

  test('Test overwritten addArc method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..addArc(rect(), 0.5, 22.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..addArc(rect(), 0.5, 22.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten addOval method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..addOval(rect());
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..addOval(rect());
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten addPolygon method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..addPolygon(points(), true);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..addPolygon(points(), true);
    expect(comparePaths(pe1, pe2), true);
  });
  test('Test overwritten addRect method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..addRect(rect());
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..addRect(rect());
    expect(comparePaths(pe1, pe2), true);
  });
  test('Test overwritten addRRect method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..addRRect(rRect());
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..addRRect(rRect());
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten close method', () {
    Path p1;
    PathExtended pe1;
    pe1 = pe()..lineTo(1.0, 0);
    p1 = p()..lineTo(1.0, 0);
    //Test if segment gets closed
    expect(pe1.computeMetrics().last.isClosed, false);
    expect(p1.computeMetrics().last.isClosed, false);
    pe1.close();
    p1.close();
    //Test if segment gets closed
    expect(pe1.computeMetrics().last.isClosed, true);
    expect(p1.computeMetrics().last.isClosed, true);
    //Test where current point continues
    pe1.lineTo(1.0, 1.0);
    p1.lineTo(1.0, 1.0);
    expect(comparePaths(pe1, p1), true);
  });

  test('Test overwritten arcTo method', () {
    //Case1: no partial segment existent
    Path p1;
    PathExtended pe1, pe2;
    p1 = p()..arcTo(rect(), 5.0, 2.0, true);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()..arcTo(rect(), 5.0, 2.0, true);
    expect(comparePaths(pe1, pe2), true);
    //Case2: Partial segment existent
    p1 = p()
      ..addRect(rect())
      ..arcTo(rect(), 5.0, 2.0, true);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pe()
      ..addRect(rect())
      ..arcTo(rect(), 5.0, 2.0, true);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten arcToPoint method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()
      ..arcToPoint(Offset(1, 1),
          radius: radius(), rotation: 0.0, largeArc: false, clockwise: true);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()
      ..arcToPoint(Offset(1, 1),
          radius: radius(), rotation: 0.0, largeArc: false, clockwise: true);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten conicTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..conicTo(1.0, 2.0, 3.0, 4.0, 5.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..conicTo(1.0, 2.0, 3.0, 4.0, 5.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten cubicTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..cubicTo(1.0, 2.0, 3.0, 4.0, 5.0, 6.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..cubicTo(1.0, 2.0, 3.0, 4.0, 5.0, 6.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten lineTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..lineTo(1.0, 2.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..lineTo(1.0, 2.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten quadraticBezierTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..quadraticBezierTo(1.0, 2.0, 3.0, 4.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..quadraticBezierTo(1.0, 2.0, 3.0, 4.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten relativeArcToPoint method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()
      ..relativeArcToPoint(Offset(1.0, 2.0),
          radius: radius(), rotation: 0.0, largeArc: false, clockwise: true);

    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()
      ..relativeArcToPoint(Offset(1.0, 2.0),
          radius: radius(), rotation: 0.0, largeArc: false, clockwise: true);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten relativeConicTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..relativeConicTo(1.0, 2.0, 3.0, 4.0, 5.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..relativeConicTo(1.0, 2.0, 3.0, 4.0, 5.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten  relativeCubicTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..relativeCubicTo(1.0, 2.0, 3.0, 4.0, 5.0, 6.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..relativeCubicTo(1.0, 2.0, 3.0, 4.0, 5.0, 6.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten  relativeLineTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..relativeLineTo(1.0, 2.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..relativeLineTo(1.0, 2.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten relativeQuadraticBezierTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..relativeQuadraticBezierTo(1.0, 2.0, 3.0, 4.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..relativeQuadraticBezierTo(1.0, 2.0, 3.0, 4.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten extendWithPath method', () {
    final Path path = Path()
      ..moveTo(1.0, 1.0)
      ..lineTo(2.0, 2.0);
    Path p1;
    PathExtended pe1, pe2;

    //Create pe and p with two preceeding segments
    p1 = p()
      ..lineTo(1.0, 1.0)
      ..moveTo(5.0, 5.0)
      ..lineTo(1.0, 1.0);
    pe2 = pe()
      ..lineTo(1.0, 1.0)
      ..moveTo(5.0, 5.0)
      ..lineTo(1.0, 1.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    expect(comparePaths(pe1, pe2), true);

    //Test extendWithPath
    p1.extendWithPath(path, Offset.zero);
    pe2.extendWithPath(path, Offset.zero);
    pe1 = pe()..addPath(p1, Offset.zero);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten moveTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()..moveTo(1.0, 2.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()..moveTo(1.0, 2.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten relativeMoveTo method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0);
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0);
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten reset method', () {
    Path p1;
    PathExtended pe1, pe2;
    p1 = ps()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0)
      ..reset();
    pe1 = pe()..addPath(p1, Offset.zero);
    pe2 = pes()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0)
      ..reset();
    expect(comparePaths(pe1, pe2), true);
  });

  test('Test overwritten shift method', () {
    Path p1, p2;
    PathExtended pe1, pe2;
    p1 = p()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 0)
      ..lineTo(0, 0);
    p1 = p1.shift(Offset(20, 0));
    pe1 = pe()..addPath(p1, Offset.zero);
    p1 = pe1.shift(Offset.zero);

    pe2 = pe()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 0)
      ..lineTo(0, 0);
    p2 = pe2.shift(Offset(20, 0));
    expect(comparePaths(p1, p2), true);
  });

  test('Test overwritten transform method', () {
    Path p1, p2;
    PathExtended pe1, pe2;
    p1 = p()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0)
      ..lineTo(0, 0);
    p1 = p1.transform(Matrix4.translation(Vector3(1, 2, 0)).storage);
    pe1 = pe()..addPath(p1, Offset.zero);
    p1 = pe1.shift(Offset.zero);
    pe2 = pe()
      ..moveTo(10.0, 10.0)
      ..relativeMoveTo(1.0, 2.0)
      ..lineTo(0, 0);
    p2 = pe2.transform(Matrix4.translation(Vector3(1, 2, 0)).storage);
    expect(comparePaths(p1, p2), true);
  });
}

PathExtended pe() {
  return PathExtended()..applyPathEffect(ContinousLine());
}

Path p() {
  return Path();
}

//Both represenations but with prev segment
PathExtended pes() {
  return PathExtended()
    ..addRect(rect())
    ..applyPathEffect(ContinousLine());
}

Path ps() {
  return Path()..addRect(rect());
}
