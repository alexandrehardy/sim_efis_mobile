import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/text_style.dart';

class CheckListEntry {
  final String prompt;
  final String expected;
  final bool isHeading;

  const CheckListEntry({
    required this.prompt,
    required this.expected,
    required this.isHeading,
  });

  CheckListEntry copyWith({
    String? prompt,
    String? expected,
    bool? isHeading,
  }) {
    return CheckListEntry(
      prompt: prompt ?? this.prompt,
      expected: expected ?? this.expected,
      isHeading: isHeading ?? this.isHeading,
    );
  }
}

class CheckList {
  final String name;
  final String path;
  final List<CheckListEntry> entries;

  const CheckList({
    required this.name,
    required this.path,
    required this.entries,
  });

  CheckList copyWith({
    String? name,
    String? path,
    List<CheckListEntry>? entries,
  }) {
    return CheckList(
      name: name ?? this.name,
      path: path ?? this.path,
      entries: entries ?? this.entries,
    );
  }
}

class CheckListItem extends StatelessWidget {
  final String prompt;
  final String expected;
  final bool isHeading;

  const CheckListItem({
    Key? key,
    required this.prompt,
    required this.expected,
    this.isHeading = false,
  }) : super(key: key);

  CheckListItem.fromCheckListEntry({
    Key? key,
    required CheckListEntry entry,
  })  : prompt = entry.prompt,
        expected = entry.expected,
        isHeading = entry.isHeading,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isHeading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            prompt,
            style: EfisStyle.settingsTextStyle.copyWith(
              fontSize: 20,
              color: EfisColors.checkListHeading,
            ),
          ),
          const Divider(color: Colors.white),
        ],
      );
    }
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white38),
          //top: BorderSide(color: Colors.white38),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //TODO: Expanded is not right, but letting
            // it size itself is not right either.
            Expanded(
              flex: 2,
              child: Text(
                prompt,
                textAlign: TextAlign.left,
                style: EfisStyle.settingsTextStyle,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                expected,
                style: EfisStyle.settingsTextStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
