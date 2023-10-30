import 'dart:io';

import 'package:easy_folder_picker/FolderPicker.dart';
import 'package:flutter/material.dart';
import 'package:hello_euc/models/activity.dart';
import 'package:hello_euc/models/enums/export_type.dart';
import 'package:permission_handler/permission_handler.dart';

class Export extends StatefulWidget {
  final Activity activity;

  const Export({super.key, required this.activity});

  @override
  State<StatefulWidget> createState() {
    return _ExportState();
  }
}

class _ExportState extends State<Export> {
  export(ExportType type) async {
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status != PermissionStatus.granted || !context.mounted) {
      return;
    }

    Directory? directory = await FolderPicker.pick(
      allowFolderCreation: true,
      rootDirectory: Directory(FolderPicker.rootPath),
      context: context,
    );

    if (directory == null || !context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No directory selected")));
      return;
    }

    if (widget.activity.name != null && widget.activity.name!.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No activity name.")));
      return;
    }

    File file =
        File("${directory.path}/${widget.activity.name}.${type.extension}");

    file.writeAsStringSync(widget.activity.getFileContent(type));

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("${file.path} saved.")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Export"),
        OverflowBar(
          children: ExportType.values
              .map((e) => TextButton(
                  onPressed: () => export(e), child: Text(e.toString())))
              .toList(),
        )
      ],
    );
  }
}
