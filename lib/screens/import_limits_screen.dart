import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/snackbars.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class ImportAircraftLimitsScreen extends StatefulWidget {
  const ImportAircraftLimitsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ImportAircraftLimitsScreen> createState() =>
      _ImportAircraftLimitsScreenState();
}

class _ImportAircraftLimitsScreenState
    extends State<ImportAircraftLimitsScreen> {
  String limitText = '';

  Future<bool> saveFile(List<String> fileContent) async {
    if (fileContent.isEmpty) {
      return false;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory aircraftDir = Directory('${appDocDir.path}/aircraft');
    await aircraftDir.create(recursive: true);

    Map<String, String> values = {};
    for (String line in fileContent) {
      List<String> parts = line.split('=');
      if (parts.length == 2) {
        values[parts[0].trim()] = parts[1].trim();
      }
    }
    String? aircraftCode = values['aircraft'];
    if (aircraftCode == null) {
      return false;
    }

    File limitsFile = File('${aircraftDir.path}/$aircraftCode.limits');
    bool fileExists = await limitsFile.exists();
    bool doSave = true;

    if (fileExists) {
      bool? result;
      if (mounted) {
        result = await showDialog(
          context: context,
          builder: (BuildContext context) => AcceptDialog(
            message: 'Aircraft file $aircraftCode already exists, replace it?',
          ),
        );
      }
      doSave = (result != null) && (result);
    }

    if (doSave) {
      await limitsFile.writeAsString(fileContent.join('\n'));
      if (mounted) {
        showSuccessSnackBar(
          context: context,
          message: 'Saved parameters for $aircraftCode',
        );
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPORT AIRCRAFT'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () async {
              List<String> fileContent = [];
              bool importSuccess = false;
              for (String line in limitText.split('\n')) {
                if (line.trim().isEmpty) {
                  importSuccess = await saveFile(fileContent) || importSuccess;
                  fileContent = [];
                } else {
                  fileContent.add(line.trim());
                }
              }
              importSuccess = await saveFile(fileContent) || importSuccess;
              if (!importSuccess) {
                if (context.mounted) {
                  showErrorSnackBar(
                    context: context,
                    message: 'No aircraft in provided text',
                  );
                }
              }
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'IMPORT',
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
        color: EfisColors.backgroundDark,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Paste the aircraft text here:',
                  style: EfisStyle.settingsTextStyle,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: EfisTextField(
                    maxLines: 1000,
                    onChanged: (value) {
                      limitText = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
