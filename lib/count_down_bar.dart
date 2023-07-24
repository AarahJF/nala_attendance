
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountdownBar extends StatefulWidget {
  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  double progress = 1.0;
  int secondsRemaining = 45;
  Color barColor = Colors.green;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
          if (secondsRemaining <= 30 && secondsRemaining > 15) {
            barColor = Colors.yellow;
          } else if (secondsRemaining <= 15 && secondsRemaining > 0) {
            barColor = Colors.red;
          }
          progress = secondsRemaining / 45;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      valueColor: AlwaysStoppedAnimation<Color>(barColor),
      backgroundColor: Colors.grey[300],
    );
  }
}
