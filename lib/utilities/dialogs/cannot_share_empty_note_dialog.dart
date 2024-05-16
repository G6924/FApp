import 'package:flutter/material.dart';
import 'package:project/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Sharing',
    content: 'you cannot share an empty note!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}