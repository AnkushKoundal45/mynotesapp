import 'package:flutter/widgets.dart';
import 'package:mynotes/utilities/dialogs/generic_dialogs.dart';

Future<void> showPasswordResetDialog(BuildContext context) {
  return showGenricDialog(
    context: context,
    title: 'Password Reset',
    content:
        'We have sent you an email for password reset. Please open your email for more information',
    optionBuilder: () => {
      'OK': null,
    },
  );
}
