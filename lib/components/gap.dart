import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double height;
  const Gap({super.key, this.height = 50});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
