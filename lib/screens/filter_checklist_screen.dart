import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/screens/new_checklist_screen.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/widgets/accept_dialog.dart';
import 'package:sim_efis/widgets/floating_button.dart';

class FilterCheckListsScreen extends StatefulWidget {
  final List<String> availableCheckLists;

  const FilterCheckListsScreen({
    Key? key,
    required this.availableCheckLists,
  }) : super(key: key);

  @override
  State<FilterCheckListsScreen> createState() => _FilterCheckListsScreenState();
}

class _FilterCheckListsScreenState extends State<FilterCheckListsScreen> {
  List<String> selected = [];
  List<String> availableCheckLists = [];

  @override
  void initState() {
    super.initState();
    selected = List.from(UiStateController.state.availableCheckLists);
    availableCheckLists = List.from(widget.availableCheckLists);
    availableCheckLists.sort(
      (String a, String b) => a.toLowerCase().compareTo(b.toLowerCase()),
    );
  }

  Future<void> deleteCheckList(String name) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory checkListDir = Directory('${appDocDir.path}/checklist');
    File checkListFile = File('${checkListDir.path}/$name.checks');
    if (await checkListFile.exists()) {
      await checkListFile.delete();
      Settings.removeChecklist(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter checklists'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () {
              Navigator.of(context).pop(selected);
            },
            label: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'FILTER',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: availableCheckLists
                        .map(
                          (e) => Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      if (selected.contains(e))
                                        const Icon(
                                          Icons.check,
                                          size: 32,
                                          color: Colors.green,
                                        ),
                                      if (!selected.contains(e))
                                        const SizedBox.square(
                                          dimension: 32,
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(e),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    if (selected.contains(e)) {
                                      setState(() {
                                        selected.remove(e);
                                      });
                                    } else {
                                      setState(() {
                                        selected.add(e);
                                      });
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () async {
                                  File? newFile = await Navigator.push(
                                    context,
                                    MaterialPageRoute<File>(
                                      builder: (BuildContext context) =>
                                          NewChecklistScreen(
                                        checklist: Settings.checkLists[e],
                                      ),
                                    ),
                                  );
                                  if (newFile != null) {
                                    await Settings.loadCheckList(newFile);
                                  }
                                  setState(() {
                                    // Get the state reloaded
                                  });
                                },
                              ),
                              GestureDetector(
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () async {
                                  bool? result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AcceptDialog(
                                      message: 'Delete checklist "$e"?',
                                    ),
                                  );
                                  bool doDelete = (result != null) && (result);
                                  if (doDelete) {
                                    await deleteCheckList(e);
                                    setState(() {
                                      availableCheckLists.remove(e);
                                    });
                                  }
                                },
                              ),
                            ],
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
