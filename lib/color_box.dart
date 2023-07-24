import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorBox extends StatelessWidget {
  final Color color;
  final int count;

  const ColorBox({
    Key? key,
    required this.color,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 30,
      color: color,
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}