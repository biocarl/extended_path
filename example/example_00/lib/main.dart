import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:extended_path/extended_path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool start = false;
  bool run = false;
  Directory storageDir;
  String parentFolder = "extended_path";
  //Resulting in  a folder called `simple` containing simple_0.png ... simple_100.png
  String projectName = "path_dash_line";

  //Custom
  List<Path> paths;
  List<Path> createPaths() {
    List<Path> paths = List();

    //Bounding box
    paths.add(Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 5)));

    // Path element = Path()
    // ..addRect(Rect.fromCircle(center: Offset.zero, radius: 1));
    // circle(0,2);
    //Create sin
    // Path path1 = Path();
    // double y;
    // path1.moveTo(0, 180);
    // for (double x = 0; x <= 360; x++) {
    // y = 180.0 - sin(x * pi / 180) * 120;
    // path1.lineTo(x, y);
    // }
    // // path1 = PathExtended(path1)..applyPathEffect(DashPathEffect([2,2,5,2,2,5], dashOffset: 0));
    // path1 = PathExtended(path1)..applyPathEffect(PathDashPathEffect(element,[2,2,5,2,2,5]));
    // paths.add(path1);
    // //Line
    // Path path2 = Path();
    // path2.moveTo(0,180);
    // path2.lineTo(360,180);
    // // path2 = PathExtended(path2)..applyPathEffect(DashPathEffect([5,5], dashOffset: 0));
    // path2 = PathExtended(path2)..applyPathEffect(PathDashPathEffect(element,[5,5]));
    // paths.add(path2);

    // Path path = Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 50));
    // paths.add(path);

    // Path element = circle(0,40.0);
    PathExtended sp = PathExtended(circle(0, 1000.0));
    // PathExtended sp = PathExtended();
    // sp.addPath(circle(0, 1.2), Offset.zero);
    sp.applyPathEffect(ContinousLine());
    paths.add(sp);
    // paths.add(path1);

    // sp.addPath(circle(0,20.0),Offset.zero);
    // sp.addPath(circle(0,10.0),Offset.zero);
    // // sp.applyPathEffect(DashPathEffect([2,2], dashOffset: 0));
    // sp.applyPathEffect(PathDashPathEffect(element,[2,2]));

    // path.addPath(sp,Offset.zero);
    // paths.add(sp);

    return paths;
  }

  Path circle(double pos, double radius) {
    return Path()
      ..addOval(Rect.fromCircle(center: Offset(pos, pos), radius: radius));
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  //Stores project folders on external storage of the phone
  Future<void> requestPermissions() async {
    var res = await SimplePermissions.requestPermission(
        Permission.WriteExternalStorage);
    if (res == PermissionStatus.authorized) {
      //External storage
      this.storageDir = (await getExternalStorageDirectory());
      //current project
      this.storageDir = Directory(
          "${this.storageDir.path}/${this.parentFolder}/${this.projectName}");
      //Replace existing project folder
      if (await this.storageDir.exists())
        this.storageDir.deleteSync(recursive: true);
      this.storageDir = await this.storageDir.create(recursive: true);
      setState(() {
        this.start = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.paths = createPaths();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
                this.run = !this.run;
              }),
          child: Icon((this.run) ? Icons.stop : Icons.play_arrow)),
      body: Center(
          child: Column(children: <Widget>[
        (this.start)
            ? Expanded(
                child: AnimatedDrawing.paths(
                this.paths,
                paints: [
                  // Paint()
                  // ..color=Colors.blue
                  // ..strokeWidth = 1.0
                  // ..style = PaintingStyle.stroke,
                  // Paint()
                  // ..color=Colors.red
                  // ..strokeWidth = 1.0
                  // ..style = PaintingStyle.stroke,
                  // Paint()
                  // ..color = Colors.black
                  // ..strokeWidth = 1.0
                  // ..style = PaintingStyle.stroke,
                  Paint()
                    ..color = Colors.black
                    // ..strokeWidth = 1.0
                    ..style = PaintingStyle.stroke,
                  Paint()
                    ..color = Colors.black
                    // ..strokeWidth = 1.0
                    ..style = PaintingStyle.stroke,
                ],
                run: this.run,
                duration: Duration(seconds: 1),
                lineAnimation: LineAnimation.oneByOne,
                // lineAnimation: LineAnimation.allAtOnce,
                animationCurve: Curves.linear,
                onFinish: () => setState(() {
                      this.run = false;
                    }),
                //Uncomment this to write each frame to file
                debug: DebugOptions(
                  fileName: this.projectName,
                  showBoundingBox: false,
                  showViewPort: false,
                  recordFrames: false,
                  // recordFrames: true,
                  resolutionFactor: 5.0,
                  outPutDir: this.storageDir.path,
                ),
              ))
            : Container(),
      ])),
    );
  }
}

// import 'package:extended_path/extended_path.dart';
// import 'package:drawing_animation/drawing_animation.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         title: 'Flutter Demo',
//         theme: ThemeData(
//             primarySwatch: Colors.blue,
//         ),
//         home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   Path circle(double pos, double radius){
//       return Path() ..addOval(Rect.fromCircle(center: Offset(pos,pos), radius: radius));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     //Border
//     // Path path = Path()..addRect(Rect.fromCircle(center: Offset.zero, radius: 50));
//     Path path = Path();
//     //Play arround
//     // path.addPath(Path() ..addRect(Rect.fromCircle(center: Offset.zero, radius: 2.0)),Offset.zero);
//     Path element = circle(0,40.0);
//     // PathExtended sp = PathExtended(circle(0,40.0));
//     PathExtended sp = PathExtended();
//     sp.addPath(circle(0,30.0),Offset.zero);
//     sp.addPath(circle(0,20.0),Offset.zero);
//     // sp.applyPathEffect(DashPathEffect([2,2], dashOffset: 0));
//     sp.applyPathEffect(PathDashPathEffect(element,[2,2]));
//     // sp.applyPathEffect(ContinousLine());
//     sp.addPath(circle(0,30.0)..addPath(circle(0,40),Offset.zero)..addPath(circle(0,50),Offset.zero),Offset.zero);
//     // sp.addPath(circle(0,20.0),Offset.zero);
//
//     path.addPath(sp,Offset.zero);
//     // path.addPath(sp.sampled,Offset.zero);
//     // path.addPath(sp.original,Offset(2.0,0));
//     // path.addPath(sp.original,Offset(-2.0,0));
//
//     // path.addPath(Path()..addRect(path.getBounds().inflate(16.0)),Offset.zero);
//
//     //scale canvas
//     Size media = MediaQuery.of(context).size;
//     double dx =  media.width / path.getBounds().width;
//
//     return Scaffold(
//         appBar: AppBar(
//             // Here we take the value from the MyHomePage object that was created by
//             // the App.build method, and use it to set our appbar title.
//             title: Text(widget.title),
//         ),
//         body: Center(
//             // Center is a layout widget. It takes a single child and positions it
//             // in the middle of the parent.
//             child: CustomPaint(
//                 painter: PathPainter(path,dx),
//                 // size: Size(300,300),
//             )
//             ),
//     );
//   }
// }
// class PathPainter extends CustomPainter {
//   PathPainter(this.path, this.scale);
//   final Path path;
//   final double scale;
//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.scale(scale,scale);
//
//     Paint p = new Paint()
//               ..color = Colors.blue
//               ..style = PaintingStyle.stroke
//               ..strokeCap = StrokeCap.square;
//               // ..strokeWidth = 1.0;
//     canvas.drawPath(path, p);
//   }
//
//   @override
//   bool shouldRepaint(PathPainter oldDelegate) => false;
// }
