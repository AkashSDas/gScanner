import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../services/models/custom_user.dart';

class AppDrawer extends StatelessWidget {
  final userDefaultImg =
      'https://images.unsplash.com/photo-1582266255765-fa5cf1a1d501?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80';

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(Constants.space * 6),
        bottomRight: Radius.circular(Constants.space * 6),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Constants.secondary),
        child: Drawer(
          elevation: 4,
          child: ListView(
            children: [
              _buildAvatar(context, user),
              _buildDrawerList(context, user),
            ],
          ),
        ),
      ),
    );
  }

  /// BUILDER FUNCTIONS

  Widget _buildAvatar(BuildContext context, User user) => Container(
        child: DrawerHeader(
          curve: Curves.easeInOut,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            backgroundImage: NetworkImage(user?.photoURL ?? userDefaultImg),
          ),
        ),
      );

  Widget _buildDrawerList(BuildContext context, User user) {
    CustomUser userModel = Provider.of<CustomUser>(context);

    return Container(
      child: Column(
        children: [
          _buildDrawerItem(
            context,
            FontAwesome.user_o,
            user?.displayName ?? 'Guest',
            style: Theme.of(context).textTheme.headline4,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          _buildDrawerItem(
            context,
            FontAwesome.envelope_o,
            user?.email ?? 'guest@mail.io',
          ),
          _buildDrawerItem(
            context,
            FontAwesome.calendar_o,
            userModel?.createdAt ?? 'no idea',
          ),
          Divider(color: Colors.white60),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData iconData,
    String text, {
    Function onTap,
    TextStyle style,
  }) =>
      InkWell(
        onTap: onTap != null ? onTap : () {},
        child: ListTile(
          leading: Icon(iconData, color: Colors.white),
          title: Text(
            text,
            style:
                style != null ? style : Theme.of(context).textTheme.bodyText1,
          ),
        ),
      );
}
