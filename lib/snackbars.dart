import 'package:flutter/material.dart';
import 'package:sim_efis/text_style.dart';

void showSuccessSnackBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(
              Icons.thumb_up,
              color: Colors.green,
            ),
          ),
          Text(
            message,
            style: EfisStyle.settingsTextStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}

void showErrorSnackBar({
  required BuildContext context,
  required String message,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: Icon(
              Icons.warning,
              color: Colors.red,
            ),
          ),
          Text(
            message,
            style: EfisStyle.settingsTextStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    ),
  );
}
