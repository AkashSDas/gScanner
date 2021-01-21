import 'package:flutter/material.dart';

import '../constants.dart';

class ModalSheet {
  static Future<void> showFileDeleteModalBottomSheet({
    @required BuildContext context,
    @required String btnLabel,
    @required Color btnColor,
    @required String msg,
  }) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => Container(
        height: 250,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(ctx).accentColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Constants.space * 2),
            topRight: Radius.circular(Constants.space * 2),
          ),
          boxShadow: [Constants.boxShadow],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(msg, style: Theme.of(ctx).textTheme.bodyText1),
            FlatButton(
              color: btnColor,
              child: Text(
                btnLabel,
                style: Theme.of(ctx).textTheme.headline3,
              ),
              onPressed: () {
                /// Removing the modal sheet widget
                Navigator.pop(ctx);

                /// Removing the alert dialog box widget which asked
                /// whether the user want to delete the file or not
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
