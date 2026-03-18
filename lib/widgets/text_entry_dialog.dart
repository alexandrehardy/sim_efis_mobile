import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/efis_button.dart';
import 'package:sim_efis/widgets/efis_text_field.dart';

class TextEntryDialog extends StatefulWidget {
  final String message;
  const TextEntryDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<TextEntryDialog> {
  String value = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EfisColors.background,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 10.0),
              Text(
                widget.message,
                style: EfisStyle.settingsTextStyle.copyWith(fontSize: 16),
                maxLines: 3,
              ),
              const SizedBox(height: 10.0),
              EfisTextField(
                fontSize: 16,
                compact: true,
                onChanged: (String value) {
                  this.value = value;
                },
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EfisButton(
                    text: 'OK',
                    align: TextAlign.center,
                    onPressed: () {
                      Navigator.of(context).pop(value);
                    },
                  ),
                  const SizedBox(width: 30.0),
                  EfisButton(
                    text: 'CANCEL',
                    align: TextAlign.center,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
