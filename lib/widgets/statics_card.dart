import 'package:flutter/material.dart';

class StaticsCard extends StatelessWidget {
  final double height;

  const StaticsCard({this.height = 150, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(height / 8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: height,
      width: double.infinity,
      child: const Center(
          child: Text(
        'statics',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }
}
