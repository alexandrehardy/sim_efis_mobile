import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/widgets/floating_button.dart';
import 'package:sim_efis/widgets/radio_group.dart';

class FileOption {
  final String name;
  final String path;
  const FileOption({required this.name, required this.path});
}

class LoadAircraftLimitsScreen extends StatefulWidget {
  final String aircraft;
  final List<String> options;
  const LoadAircraftLimitsScreen({
    Key? key,
    required this.aircraft,
    required this.options,
  }) : super(key: key);

  @override
  State<LoadAircraftLimitsScreen> createState() =>
      _LoadAircraftLimitsScreenState();
}

class _LoadAircraftLimitsScreenState extends State<LoadAircraftLimitsScreen> {
  List<FileOption> annotateOptions = [];
  Map<String, FileOption> nameToFile = {};
  String selected = '';

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
    selected = annotateOptions.first.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Load parameters for ${widget.aircraft}'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () {
              Navigator.of(context).pop(nameToFile[selected]!.path);
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'LOAD',
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
                  child: RadioGroup(
                    settings: annotateOptions.map((e) => e.name).toList(),
                    selected: selected,
                    onChanged: (String value) {
                      selected = value;
                    },
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
