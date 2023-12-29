import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialogs.dart';

Future<bool> showDeleteDialog(
  BuildContext context,
) {
  return showGenricDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item ?',
    optionBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
