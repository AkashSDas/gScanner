import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../constants.dart';

class AppBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Using Container and ClipRRect for box shadow and rounded borders respectively
    return Container(
      decoration: BoxDecoration(
        boxShadow: [Constants.boxShadow],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Constants.space * 2),
          topRight: Radius.circular(Constants.space * 2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Constants.space * 2),
          topRight: Radius.circular(Constants.space * 2),
        ),
        child: _buildBottomNav(context),
      ),
    );
  }

  /// BUILDER FUNCTIONS

  Widget _buildBottomNav(BuildContext context) => BottomNavigationBar(
        items: _navItems(),
        onTap: (int idx) => _onTap(idx, context),
        backgroundColor: Theme.of(context).primaryColor,
        unselectedIconTheme: Constants.appBarUnselectedIconTheme,
        selectedIconTheme: Constants.appBarSelectedIconTheme,
        selectedItemColor: Constants.appBarSelectedItemColor,
        unselectedItemColor: Constants.appBarUnselectedItemColor,
      );

  /// FUNCTIONS

  List<BottomNavigationBarItem> _navItems() => [
        BottomNavigationBarItem(icon: Icon(AntDesign.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(FontAwesome.photo),
          label: 'Gallery',
        ),
        BottomNavigationBarItem(
          icon: Icon(FontAwesome.video_camera),
          label: 'Camera',
        ),
      ];

  void _onTap(int idx, BuildContext context) async {
    switch (idx) {
      case 0:
        // do nothing since it's the default home screen
        break;
      case 1:
        Navigator.pushNamed(context, '/pick-gallery-images');
        break;
      case 2:
        Navigator.pushNamed(context, '/pick-camera-images');
        break;
    }
  }
}
