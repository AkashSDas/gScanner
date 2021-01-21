import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../constants.dart';
import '../services/auth/auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();

    /// Delaying the check and thus the navigation to '/home
    /// and thus the built of the app to avoid the
    /// “!_debugLocked': is not true.” => error
    /// One drawback of this solution is that for few milliseconds
    /// the login screen is displayed even though the user is logged
    /// in
    Future.delayed(Duration.zero, () {
      if (_auth.getUser != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: StreamBuilder<User>(
          stream: AuthService().user,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Future.delayed(Duration.zero, () {
                Navigator.pushReplacementNamed(context, '/home');
              });
            }

            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: Constants.space * 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: FlareActor(
                      'assets/animations/gScannerLogo.flr',
                      animation: "idle",
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                  LoginBtn(
                    icon: FontAwesome.google,
                    text: 'LOGIN WITH GOOGLE',
                    loginMethod: _auth.googleSignIn,
                    color: Constants.blue2,
                  ),
                ],
              ),
            );
          },
        ),
      );
}

class LoginBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final Function loginMethod;

  LoginBtn({
    Key key,
    this.color,
    this.icon,
    this.loginMethod,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: Constants.space * 2),
        child: FlatButton.icon(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.space * 2,
            vertical: Constants.space * 1,
          ),
          icon: Icon(
            icon,
            color: Colors.white,
            size: Constants.space * 4,
          ),
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.space * 4),
          ),
          onPressed: () => loginMethod(),
          label: Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: Constants.space * 3),
              child: Text(
                '$text',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
          ),
        ),
      );
}
