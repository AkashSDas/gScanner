import 'package:flutter/material.dart';

import './modal_sheet.dart';

class DialogBox {
  /// Just Ok action can be taken
  static Future<void> displayDialogBox({
    @required String title,
    @required String description,
    @required BuildContext context,
    Function onPressed,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).accentColor,
        title: Text(title, style: Theme.of(context).textTheme.headline2),
        content: Text(
          description,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        actions: [
          TextButton(
            child: Text('Ok'),
            onPressed: onPressed != null
                ? onPressed
                : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Yes or No action can be taken
  static Future<void> displayDeleteFileYesOrNoDialog({
    @required String title,
    @required String description,
    @required BuildContext context,
    @required Function onYesPressed,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).accentColor,
        title: Text(title, style: Theme.of(ctx).textTheme.headline2),
        content: Text(
          description,
          style: Theme.of(ctx).textTheme.bodyText1,
        ),
        actions: [
          TextButton(
            child: Text('No'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: onYesPressed != null
                ? () async {
                    Map response = await onYesPressed();
                    if (response['success'] == true) {
                      ModalSheet.showFileDeleteModalBottomSheet(
                        context: ctx,
                        btnLabel: 'Ok',
                        btnColor: Colors.green,
                        msg: 'Successfully deleted the file',
                      );
                    } else {
                      ModalSheet.showFileDeleteModalBottomSheet(
                        context: ctx,
                        btnLabel: 'Ok',
                        btnColor: Colors.red,
                        msg: 'An error occured, please try again',
                      );
                    }
                  }
                : () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
