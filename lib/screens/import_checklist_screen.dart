import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/snackbars.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class ImportCheckListScreen extends StatefulWidget {
  const ImportCheckListScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ImportCheckListScreen> createState() => _ImportCheckListScreenState();
}

class _ImportCheckListScreenState extends State<ImportCheckListScreen> {
  String checklistText = '';

  Future<bool> saveFile(List<String> fileContent) async {
    if (fileContent.isEmpty) {
      return false;
    }

    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory checkListDir = Directory('${appDocDir.path}/checklist');
    await checkListDir.create(recursive: true);

    String checkListName = '';
    for (String line in fileContent) {
      if (line.trim().startsWith('#')) {
        checkListName = line.trim().substring(2);
      }
    }
    if (checkListName.isEmpty) {
      return false;
    }

    File checkListFile = File('${checkListDir.path}/$checkListName.checks');
    bool fileExists = await checkListFile.exists();
    bool doSave = true;

    if (fileExists) {
      bool? result;
      if (mounted) {
        result = await showDialog(
          context: context,
          builder: (BuildContext context) => AcceptDialog(
            message: 'Checklist $checkListName already exists, replace it?',
          ),
        );
      }
      doSave = (result != null) && (result);
    }

    if (doSave) {
      await checkListFile.writeAsString(fileContent.join('\n'));
      if (mounted) {
        showSuccessSnackBar(
          context: context,
          message: 'Saved checklist $checkListName',
        );
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPORT CHECKLIST'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () async {
              List<String> fileContent = [];
              bool importSuccess = false;
              for (String line in checklistText.split('\n')) {
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
                    message: 'No checklists in provided text',
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
                  'Paste the checklist text here:',
                  style: EfisStyle.settingsTextStyle,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: EfisTextField(
                    maxLines: 1000,
                    onChanged: (value) {
                      checklistText = value;
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
