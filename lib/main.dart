import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import './constants.dart';
import './screens/home.dart';
import './screens/login.dart';
import './screens/pick_images.dart';
import './screens/profile.dart';
import './services/auth/auth.dart';
import './shared/loader.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    Constants.changeSystemUI();

    return FutureBuilder(
      future: _initialization,
      builder: (context, AsyncSnapshot snap) {
        if (snap.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              StreamProvider<User>.value(value: AuthService().user),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: Constants.themeData,
              routes: {
                '/': (context) => SplashScreen.navigate(
                      name: 'assets/animations/gScannerLogo.flr',
                      next: (context) => Login(),
                      until: () => Future.delayed(Duration(seconds: 3)),
                      startAnimation: 'go',
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                '/home': (context) => Home(),
                '/profile': (context) => Profile(),
                '/pick-gallery-images': (context) => PickImages(
                      currentPath: '/pick-gallery-images',
                      appBarTitle: 'pick images',
                      pickImgSource: ImageSource.gallery,
                    ),
                '/pick-camera-images': (context) => PickImages(
                      currentPath: '/pick-camera-images',
                      appBarTitle: 'pick images',
                      pickImgSource: ImageSource.camera,
                    ),
              },
            ),
          );
        }
        return MaterialApp(
          home: LoadingScreen(),
          debugShowCheckedModeBanner: false,
          theme: Constants.themeData,
        );
      },
    );
  }
}
