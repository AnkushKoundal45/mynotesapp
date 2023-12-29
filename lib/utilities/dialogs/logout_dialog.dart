import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialogs.dart';

Future<bool> showLogoutDialog(
  BuildContext context,
) {
  return showGenricDialog(
    context: context,
    title: 'Logout',
    content: 'Are you sure you want to logout?',
    optionBuilder: () => {
      'Cancel': false,
      'Logout': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
