import 'dart:ui';

Rect rect() {
  return Rect.fromCircle(center: Offset.zero, radius: 3);
}

List<Offset> points() {
  return [Offset(1, 1), Offset(2, 1), Offset(4, 4)];
}

RRect rRect() {
  return RRect.fromRectAndCorners(rect());
}

Radius radius() {
  return Radius.circular(2.0);
}
