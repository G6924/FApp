import 'package:flutter/material.dart';
import 'package:project/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'delete',
    content: 'Are you sure you want delete item ?',
    optionsBuilder: () => {
      'Cancel': false,
      'yes': true,
    },
  ).then(
        (value) => value ?? false,
  );
}