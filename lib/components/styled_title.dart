import 'package:flutter/material.dart';
import 'package:hello_euc/components/gap.dart';

class StyledTitle extends StatefulWidget {
  final String title;
  final BoxConstraints constraints;
  final Color color;

  const StyledTitle(
      {super.key,
      required this.title,
      required this.constraints,
      this.color = Colors.black});

  @override
  State<StatefulWidget> createState() {
    return _StyledTitleState();
  }
}

class _StyledTitleState extends State<StyledTitle> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Gap(height: 20),
      Text(widget.title,
          style: TextStyle(
              color: widget.color,
              fontSize: widget.constraints.maxWidth / 10,
              fontWeight: FontWeight.bold)),
      const Gap(height: 20)
    ]);
  }
}
