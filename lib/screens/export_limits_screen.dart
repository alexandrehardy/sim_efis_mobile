import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/snackbars.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class FileOption {
  final String name;
  final String path;
  const FileOption({required this.name, required this.path});
}

class ExportAircraftLimitsScreen extends StatefulWidget {
  final List<String> options;
  const ExportAircraftLimitsScreen({
    Key? key,
    required this.options,
  }) : super(key: key);

  @override
  State<ExportAircraftLimitsScreen> createState() =>
      _ExportAircraftLimitsScreenState();
}

class _ExportAircraftLimitsScreenState
    extends State<ExportAircraftLimitsScreen> {
  final GlobalKey exportButtonKey = GlobalKey();
  List<FileOption> annotateOptions = [];
  Map<String, FileOption> nameToFile = {};
  List<String> selected = [];

  @override
  void initState() {
    super.initState();
    annotateOptions = widget.options
        .map((e) => FileOption(
            name: e.split('/').last.replaceAll('.limits', ''), path: e))
        .toList();
    nameToFile = {};
    for (FileOption option in annotateOptions) {
      nameToFile[option.name] = option;
    }
    selected = [];
  }

  Rect? exportButtonRect() {
    RenderObject? renderObject =
        exportButtonKey.currentContext?.findRenderObject();
    if (renderObject == null) return null;
    RenderBox renderBox = renderObject as RenderBox;

    Size size = renderBox.size;
    Offset position = renderBox.localToGlobal(Offset.zero);

    return Rect.fromCenter(
      center: position + Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXPORT AIRCRAFT'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            key: exportButtonKey,
            onPressed: () async {
              if (selected.isEmpty) {
                showErrorSnackBar(
                  context: context,
                  message: 'Please select aircraft to export',
                );
              } else {
                bool? result = await showDialog(
                  context: context,
                  builder: (BuildContext context) => const AcceptDialog(
                    message: 'Use files?',
                  ),
                );
                if (result == null) {
                  return;
                }
                bool useText = !result;

                if (useText) {
                  List<String> exports = [];
                  for (String aircraftFile in selected) {
                    String contents = await File(aircraftFile).readAsString();
                    exports.add(contents);
                  }
                  String finalExport = exports.join('\n\n');
                  await Share.share(
                    finalExport,
                    subject: 'Aircraft parameters for SIM-EFIS',
                    sharePositionOrigin: exportButtonRect(),
                  );
                } else {
                  List<String> mimetypes = [];
                  for (String _ in selected) {
                    mimetypes.add('text/plain');
                  }
                  await Share.shareXFiles(
                    selected
                        .map((e) => XFile(e, mimeType: 'text/plain'))
                        .toList(),
                    subject: 'Aircraft parameters for SIM-EFIS',
                    sharePositionOrigin: exportButtonRect(),
                  );
                }
              }
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'EXPORT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black45,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: annotateOptions
                        .map(
                          (e) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (selected.contains(e.path)) {
                                setState(() {
                                  selected.remove(e.path);
                                });
                              } else {
                                setState(() {
                                  selected.add(e.path);
                                });
                              }
                            },
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                if (selected.contains(e.path))
                                  const Icon(
                                    Icons.check,
                                    size: 32,
                                    color: Colors.green,
                                  ),
                                if (!selected.contains(e.path))
                                  const SizedBox.square(
                                    dimension: 32,
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(e.name),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
