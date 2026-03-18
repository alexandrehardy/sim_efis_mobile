import 'package:flutter/material.dart';
import 'package:sim_efis/colors.dart';
import 'package:sim_efis/text_style.dart';
import 'package:sim_efis/widgets/efis_button.dart';

class NotifyDialog extends StatelessWidget {
  final String message;
  const NotifyDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EfisColors.background,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10.0),
              Text(message,
                  style: EfisStyle.settingsTextStyle.copyWith(fontSize: 16)),
              const SizedBox(height: 10.0),
              EfisButton(
                text: 'OK',
                align: TextAlign.center,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
