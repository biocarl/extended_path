import 'package:test/test.dart';
import 'package:extended_path/extended_path.dart';
import 'package:extended_path/src/path.dart';
import 'dart:ui';

void main() {
  test('Test Path comparision method', () {
    Path element = Path()
      ..addRect(Rect.fromCircle(center: Offset.zero, radius: 1));

    Path path1 = Path();
    path1..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path1 = PathExtended(path1)
      ..applyPathEffect(PathDashPathEffect(element, [2, 2, 5, 2, 2, 5]));

    Path path2 = Path();
    path2..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path2 = PathExtended(path2)
      ..applyPathEffect(PathDashPathEffect(element, [2, 2, 5, 2, 2, 5]));

    expect(comparePaths(path1, path2), true);

    path2.addPath(element, Offset.zero);
    expect(comparePaths(path1, path2), false);

    // expect( () => parser.loadFromString( '<svg height="210" width="400"> <path stroke=" " stroke-width="5.75277775" d="M150 0 L75 200 L225 200 Z" /> </svg>'), throwsUnsupportedError);
  });

  test('Test stroke-offset', () {
    //Push with same periodicity as dash pattern -> same dash effect expected
    Path path1 = Path();
    path1..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path1 = PathExtended(path1)
      ..applyPathEffect(DashPathEffect([1, 2, 1, 2], dashOffset: 0));
    Path path2 = Path();
    path2..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path2 = PathExtended(path2)
      ..applyPathEffect(DashPathEffect([
        1,
        2,
        1,
        2,
      ], dashOffset: 3));
    expect(comparePaths(path1, path2), true);

    //Pull with same periodicity as dash pattern -> same dash effect expected
    path1 = Path();
    path1..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path1 = PathExtended(path1)
      ..applyPathEffect(DashPathEffect([1, 2, 1, 2], dashOffset: 0));
    path2 = Path();
    path2..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path2 = PathExtended(path2)
      ..applyPathEffect(DashPathEffect([
        1,
        2,
        1,
        2,
      ], dashOffset: -3));
    expect(comparePaths(path1, path2), true);

    //dash-offset bigger than dash pattern is reduced to dash pattern
    path1 = Path();
    path1..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path1 = PathExtended(path1)
      ..applyPathEffect(DashPathEffect([1, 2, 1, 2], dashOffset: -6));
    path2 = Path();
    path2..addRect(Rect.fromCircle(center: Offset.zero, radius: 3));
    path2 = PathExtended(path2)
      ..applyPathEffect(DashPathEffect([
        1,
        2,
        1,
        2,
      ], dashOffset: 6));
    expect(comparePaths(path1, path2), true);
  });
}
