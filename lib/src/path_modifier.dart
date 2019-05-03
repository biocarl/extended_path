import 'dart:ui';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

/// Base class for any style applied on _raw
abstract class PathModifier {
  /// This method iterates over sample points of each segment and manipulates those
  Offset transform(Offset offset, Offset normal) {
    throw UnimplementedError();
  }
}

/// Shifs sampled points in x/y direction based on a two-dimensional SimplexNoise.
class SimplexNoisePathModifier extends PathModifier {
  final SimplexNoise noise;

  /// Defines the intensity of the sampled points
  final int factor;
  SimplexNoisePathModifier({this.factor = 1}) : noise = SimplexNoise(Random());

  @override
  Offset transform(Offset offset, Offset normal) {
    double shift = noise.noise2D(offset.dx, offset.dy);
    return offset + Offset(shift * factor, shift * factor);
  }
}
