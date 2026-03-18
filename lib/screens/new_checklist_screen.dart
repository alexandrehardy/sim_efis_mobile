import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/logs.dart';
import 'package:sim_efis/screens/new_checklist_item_screen.dart';
import 'package:sim_efis/snackbars.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/check_list_item.dart';
import 'package:sim_efis/widgets/floating_button.dart';
import 'package:sim_efis/widgets/notify_dialog.dart';
import 'package:sim_efis/widgets/text_with_label.dart';

class NewChecklistScreen extends StatefulWidget {
  final CheckList? checklist;
  const NewChecklistScreen({Key? key, this.checklist}) : super(key: key);

  @override
  State<NewChecklistScreen> createState() => _NewChecklistScreenState();
}

class _NewChecklistScreenState extends State<NewChecklistScreen> {
  List<CheckListEntry> checklist = [];
  String name = '';

  @override
  void initState() {
    super.initState();
    if (widget.checklist != null) {
      checklist = List.from(widget.checklist!.entries);
      name = widget.checklist!.name;
    }
  }

  Widget buildCheckListItem(int i) {
    CheckListEntry entry = checklist[i];
    return Row(
      children: [
        Expanded(child: CheckListItem.fromCheckListEntry(entry: entry)),
        GestureDetector(
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          onTap: () {
            setState(() {
              checklist.remove(entry);
            });
          },
        ),
        if (i < checklist.length - 1)
          GestureDetector(
            child: const Icon(
              Icons.arrow_circle_down,
              color: Colors.white,
              size: 32,
            ),
            onTap: () {
              setState(() {
                CheckListEntry after = checklist[i + 1];
                checklist[i + 1] = entry;
                checklist[i] = after;
              });
            },
          ),
        if (i >= checklist.length - 1)
          const Icon(
            Icons.arrow_circle_down,
            color: Colors.black,
            size: 32,
          ),
        if (i > 0)
          GestureDetector(
            child: const Icon(
              Icons.arrow_circle_up,
              color: Colors.white,
              size: 32,
            ),
            onTap: () {
              setState(() {
                CheckListEntry before = checklist[i - 1];
                checklist[i - 1] = entry;
                checklist[i] = before;
              });
            },
          ),
        if (i <= 0)
          const Icon(
            Icons.arrow_circle_up,
            color: Colors.black,
            size: 32,
          ),
      ],
    );
  }

  List<Widget> buildChecklist() {
    int i;
    List<Widget> items = [];
    for (i = 0; i < checklist.length; i++) {
      items.add(buildCheckListItem(i));
    }
    return items;
  }

  Future<File?> saveCheckList() async {
    if (name.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => const NotifyDialog(
            message: 'Please specify a name for the checklist'),
      );
      return null;
    }
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory checkListDir = Directory('${appDocDir.path}/checklist');
    await checkListDir.create(recursive: true);
    File checkListFile = File('${checkListDir.path}/$name.checks');
    bool fileExists = await checkListFile.exists();
    bool doSave = true;
    if (fileExists) {
      bool? proceed;
      if (mounted) {
        proceed = await showDialog(
          context: context,
          builder: (BuildContext context) => const AcceptDialog(
            message: 'Checklist already exists. Overwrite?',
          ),
        );
      }
      if ((proceed == null) || (proceed == false)) {
        doSave = false;
      }
    }

    if (doSave) {
      try {
        List<String> contents = [];
        contents.add('# $name');
        for (CheckListEntry entry in checklist) {
          if (entry.isHeading) {
            contents.add('= ${entry.prompt}');
          } else {
            contents.add('+ ${entry.prompt} :: ${entry.expected}');
          }
        }
        await checkListFile.writeAsString(contents.join('\n'));
        return checkListFile;
      } catch (e, s) {
        Logger.logError('Failed to save checklist $name: $e', s);
        if (mounted) {
          showErrorSnackBar(
            context: context,
            message: 'Failed to save checklist $name',
          );
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New checklist'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () async {
              NavigatorState navigator = Navigator.of(context);
              File? newFile = await saveCheckList();
              if (newFile != null) {
                navigator.pop(newFile);
              }
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'SAVE',
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
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        TextWithLabel(
                          label: 'Name:',
                          onChanged: (value) {
                            name = value;
                            return true;
                          },
                          text: name,
                        ),
                        const SizedBox(height: 8),
                        const Divider(
                          color: Colors.white,
                        ),
                        ...buildChecklist(),
                        GestureDetector(
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          onTap: () async {
                            CheckListEntry? entry = await Navigator.push(
                              context,
                              MaterialPageRoute<CheckListEntry>(
                                builder: (BuildContext context) =>
                                    const NewCheckListEntryScreen(),
                              ),
                            );
                            if (entry != null) {
                              setState(() {
                                checklist.add(entry);
                              });
                            }
                          },
                        ),
                      ],
                    ),
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
