import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../constants.dart';
import '../shared/logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPath;
  final String title;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final IconButton rightIconBtn;

  CustomAppBar({
    @required this.currentPath,
    @required this.scaffoldKey,
    @required this.title,
    this.rightIconBtn,
  });

  @override
  Size get preferredSize => Size.fromHeight(80);

  @override
  Widget build(BuildContext context) => _buildWrapper(context);

  /// BUILDER FUNCTIONS

  /// This will be responsible for bg color, box shadow, border radius
  Widget _buildWrapper(BuildContext context) => Container(
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: Constants.space),
        margin: EdgeInsets.only(top: Constants.space * 2),
        decoration: BoxDecoration(
          gradient: Constants.purpleGradient,
          boxShadow: [Constants.boxShadow],
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(Constants.space * 2),
            bottomRight: Radius.circular(Constants.space * 2),
          ),
        ),
        child: _buildAppBar(context),
      );

  Widget _buildLeftActionIconBtn(BuildContext context) => currentPath == '/home'
      ? IconButton(
          icon: Icon(FontAwesome.bars),
          color: Colors.white,
          onPressed: () => scaffoldKey.currentState.openDrawer(),
        )
      : IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
        );

  Widget _buildAppBarTitle(BuildContext context) => currentPath == '/home'
      ? Logo(fontSize: 22)
      : Text(title, style: Theme.of(context).textTheme.headline2);

  Widget _buildRightActionIconBtn(BuildContext context) => rightIconBtn == null
      ? IconButton(
          icon: Icon(FontAwesome.user_o),
          color: Colors.white,
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        )
      : rightIconBtn;

  Widget _buildAppBar(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLeftActionIconBtn(context),
          _buildAppBarTitle(context),
          _buildRightActionIconBtn(context),
        ],
      );
}
