import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StopWatch extends StatefulWidget {
  const StopWatch({
    Key key,
  }) : super(key: key);

  @override
  _StopWatchState createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  final dur = const Duration(seconds: 1);
  var time = "00:00:00";
  var swatch = Stopwatch();

  void starttimer() {
    Timer(dur, keeprunning);
  }

  void keeprunning() {
    if (swatch.isRunning) {
      starttimer();
    }

    setState(() {
      time = swatch.elapsed.inHours.toString().padLeft(2, "0") +
          ":" +
          (swatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
          ":" +
          (swatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  void startwatch() {
    swatch.start();
    starttimer();
  }

  void stopwatch() {
    swatch.stop();
  }

  void resetwatch() {
    swatch.reset();
    time = "00:00:00";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 70),
            ),
            new Padding(padding: const EdgeInsets.all(5)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new FloatingActionButton(
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
                  backgroundColor: Colors.green,
                  onPressed: startwatch,
                ),
                new FloatingActionButton(
                  child: Icon(Icons.stop, color: Colors.white, size: 40),
                  backgroundColor: Colors.yellow,
                  onPressed: stopwatch,
                ),
                new FloatingActionButton(
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 40,
                  ),
                  backgroundColor: Colors.red,
                  onPressed: resetwatch,
                )
              ],
            )
          ],
        )
      ],
    );
  }
}
