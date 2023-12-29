import 'package:flutter/material.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

Future<T?> showGenricDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionBuilder,
}) {
  final options = optionBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionsTitle) {
          final value = options[optionsTitle];
          return TextButton(
              onPressed: () {
                if (value != null) {
                  Navigator.of(context).pop(value);
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text(optionsTitle));
        }).toList(),
      );
    },
  );
}
