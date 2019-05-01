import 'package:extended_path/extended_path.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Path circle(double pos, double radius) {
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(pos, pos), radius: radius));
  }

  @override
  Widget build(BuildContext context) {
    // Build your very special path :-)
    PathExtended pe = PathExtended();
    Path element = circle(0,0.5);
    pe.addPath(circle(0, 50.0), Offset.zero);
    pe.applyPathEffect(PathDashPathEffect(element,[1,1]));
    // pe.applyPathEffect(DiscretePathEffect(1,45));

    //scale canvas
    Size media = MediaQuery.of(context).size;
    double dx = media.width / pe.getBounds().width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: CustomPaint(
        painter: PathPainter(pe, dx),
      )),
    );
  }
}

class PathPainter extends CustomPainter {
  PathPainter(this.path, this.scale);
  final Path path;
  final double scale;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale, scale);

    Paint p = new Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) => false;
}
