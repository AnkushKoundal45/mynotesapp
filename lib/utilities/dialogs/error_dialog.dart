import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialogs.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenricDialog<void>(
    context: context,
    title: 'An error occured',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
