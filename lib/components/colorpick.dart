import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hello_euc/models/activity.dart';

class ColorPick extends StatefulWidget {
  final Activity activity;
  final BoxConstraints constraints;
  final Function(Color) onColorChanged;

  const ColorPick(
      {super.key,
      required this.activity,
      required this.constraints,
      required this.onColorChanged});

  @override
  State<StatefulWidget> createState() {
    return _ColorPickState();
  }
}

class _ColorPickState extends State<ColorPick> {
  _onColorChanged(Color color) {
    setState(() {
      widget.activity.color = color;
    });
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: widget.activity.color != null
                ? MaterialStateProperty.all(widget.activity.color)
                : null),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text("Color Picker"),
                    content: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxHeight: widget.constraints.maxHeight / 2),
                        child: ColorPicker(
                            colorPickerWidth: widget.constraints.maxWidth / 3,
                            paletteType: PaletteType.hueWheel,
                            labelTypes: const [],
                            enableAlpha: false,
                            pickerColor: widget.activity.color!,
                            onColorChanged: _onColorChanged)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      )
                    ],
                  ));
        },
        child: null);
  }
}
