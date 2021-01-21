import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../services/auth/auth.dart';
import '../shared/app_bar.dart';
import '../shared/drawer.dart';

class Profile extends StatelessWidget {
  /// Using a GlobalKey for the Custom Drawer to work
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final AuthService _auth = AuthService();

  final String defaultUsrImg =
      'https://images.unsplash.com/photo-1582266255765-fa5cf1a1d501?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80';

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: CustomAppBar(
        currentPath: '/profile',
        scaffoldKey: _scaffoldKey,
        title: 'profile',
        rightIconBtn: IconButton(
          icon: Icon(AntDesign.home),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
      ),
      drawer: AppDrawer(),
      body: _buildBody(user, context),
    );
  }

  /// BUILDER FUNCTIONS

  Widget _buildBody(User user, BuildContext context) => Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: Constants.space * 10,
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: NetworkImage(user?.photoURL ?? defaultUsrImg),
            ),
            SizedBox(height: Constants.space * 2),
            Text(
              user?.displayName != null ? user.displayName : 'Guest',
              style: Theme.of(context).textTheme.headline2,
            ),
            SizedBox(height: Constants.space * 2),
            Text(
              user?.email != null ? user.email : 'No email address',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: Constants.space * 2),
            FlatButton(
              color: Constants.blue2,
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Text(
                'logout',
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
          ],
        ),
      );
}
