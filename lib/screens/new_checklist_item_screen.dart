import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/check_list_item.dart';
import 'package:sim_efis/widgets/floating_button.dart';
import 'package:sim_efis/widgets/text_with_label.dart';

class NewCheckListEntryScreen extends StatefulWidget {
  const NewCheckListEntryScreen({Key? key}) : super(key: key);

  @override
  State<NewCheckListEntryScreen> createState() =>
      _NewCheckListEntryScreenState();
}

class _NewCheckListEntryScreenState extends State<NewCheckListEntryScreen> {
  CheckListEntry entry = const CheckListEntry(
    prompt: '',
    expected: '',
    isHeading: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New checklist item'),
        backgroundColor: EfisColors.background,
        actions: [
          FloatingButton(
            onPressed: () {
              Navigator.of(context).pop(entry);
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.black,
                            fillColor: WidgetStateProperty.all(Colors.white),
                            value: entry.isHeading,
                            onChanged: (checked) {
                              setState(() {
                                entry = entry.copyWith(isHeading: checked);
                              });
                            },
                          ),
                          const Expanded(
                              child: Text(
                            'Make this a heading',
                            style: EfisStyle.settingsTextStyle,
                          )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextWithLabel(
                        label: (entry.isHeading) ? 'Heading:' : 'Prompt:',
                        onChanged: (value) {
                          entry = entry.copyWith(prompt: value);
                          return true;
                        },
                        text: '',
                      ),
                      const SizedBox(height: 10),
                      if (!entry.isHeading)
                        TextWithLabel(
                          label: 'Expected:',
                          onChanged: (value) {
                            entry = entry.copyWith(expected: value);
                            return true;
                          },
                          text: '',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
