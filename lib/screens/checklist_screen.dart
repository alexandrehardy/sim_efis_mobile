import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sim_efis/data/ui_state.dart';
import 'package:sim_efis/screens/filter_checklist_screen.dart';
import 'package:sim_efis/screens/new_checklist_screen.dart';
import 'package:sim_efis/settings.dart';
import 'package:sim_efis/widgets/check_list_item.dart';
import 'package:sim_efis/widgets/efis_button.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({Key? key}) : super(key: key);

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Settings.loadAvailableChecklists().then(
      (value) {
        setState(() {
          // Force load due to change in state.
        });
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget buildChecklist() {
    return StreamBuilder<UiState>(
      stream: UiStateController.stream,
      initialData: UiStateController.state,
      builder: (context, snapshot) {
        List<CheckListEntry> items =
            (Settings.checkLists[snapshot.requireData.activeCheckList] ??
                    CheckList(
                      name: snapshot.requireData.activeCheckList,
                      path: '',
                      entries: [],
                    ))
                .entries;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ...items
                .map((e) => CheckListItem(
                      prompt: e.prompt,
                      expected: e.expected,
                      isHeading: e.isHeading,
                    )),
            const SizedBox(height: 100, width: double.maxFinite),
          ],
        );
      },
    );
  }

  List<Widget> buildButtons({
    required List<String> checkListNames,
    required String selected,
    required List<String> available,
  }) {
    List<Widget> buttons = [];
    for (String name in checkListNames) {
      if ((available.isNotEmpty) && (!available.contains(name))) {
        continue;
      }
      buttons.add(
        EfisButton(
          text: name,
          align: TextAlign.center,
          onPressed: () {
            UiStateController.setChecklist(name);
          },
          selected: name == selected,
        ),
      );
    }
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: StreamBuilder<UiState>(
            stream: UiStateController.stream,
            initialData: UiStateController.state,
            builder: (context, snapshot) {
              List<String> checkListNames = Settings.checkLists.keys.toList();
              checkListNames.sort(
                (String a, String b) =>
                    a.toLowerCase().compareTo(b.toLowerCase()),
              );
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...buildButtons(
                    checkListNames: checkListNames,
                    selected: snapshot.requireData.activeCheckList,
                    available: snapshot.requireData.availableCheckLists,
                  ),
                  EfisButton(
                    text: 'ADD NEW',
                    align: TextAlign.center,
                    onPressed: () async {
                      File? newFile = await Navigator.push(
                        context,
                        MaterialPageRoute<File>(
                          builder: (BuildContext context) =>
                              const NewChecklistScreen(),
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
                  EfisButton(
                    text: 'FILTER',
                    align: TextAlign.center,
                    onPressed: () async {
                      int checklistCount = Settings.checkLists.length;
                      List<String>? selected = await Navigator.push(
                        context,
                        MaterialPageRoute<List<String>>(
                          builder: (BuildContext context) =>
                              FilterCheckListsScreen(
                            availableCheckLists:
                                Settings.checkLists.keys.toList(),
                          ),
                        ),
                      );
                      bool setAvailable = false;
                      if (selected != null) {
                        setAvailable = true;
                      }
                      selected =
                          selected ?? snapshot.requireData.availableCheckLists;
                      if (checklistCount != Settings.checkLists.length) {
                        // Deleted checklists.
                        setAvailable = true;
                        selected = selected
                            .where(
                                (key) => Settings.checkLists.containsKey(key))
                            .toList();
                      }
                      if (setAvailable) {
                        UiStateController.setAvailableCheckLists(selected);
                      }
                    },
                  ),
                  const SizedBox(width: 50),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black45,
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: buildChecklist(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
