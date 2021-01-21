import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Majority of the ui related things constants are here
/// the rest is handled by Theme.of(context)
class Constants {
  // .0 since the measurements are of type double
  static const space = 10.0;

  /// Font Families
  static const fontHead = 'Montserrat';
  static const fontBody = 'Montserrat';

  /// Colors

  static const primary = Color(0xFF0C0B0B);
  static const secondary = Color(0xFF1D1D1D);
  static const purple1 = Color(0xFF7749C1);
  static const purple2 = Color(0xFF652FBD);
  static const purple3 = Color(0xFF6415E4);
  static const blue1 = Color(0xFFB6DCFF);
  static const blue2 = Color(0xFF0A89FF);
  static const blue3 = Color(0xFF3F3CFF);
  static const red1 = Color(0xFFFFC7C7);
  static const red2 = Color(0xFFFF0A0A);
  static const text1 = Colors.white;
  static const text2 = Colors.white70;

  /// Gradients

  static const purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purple1, purple2],
    // tileMode: TileMode.clamp,
  );

  /// Box Shadows

  static const boxShadow = BoxShadow(
    color: Colors.black54,
    blurRadius: 10,
    offset: Offset(4, 4),
  );

  /// Text Styles

  static const cHeadline2 = TextStyle(
    fontSize: 22,
    color: Colors.white,
    fontFamily: fontHead,
    fontWeight: FontWeight.w800,
  );

  static const cHeadline3 = TextStyle(
    color: text1,
    fontSize: 14,
    fontFamily: fontHead,
    fontWeight: FontWeight.w800,
  );

  static const cHeadline4 = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: fontHead,
    fontWeight: FontWeight.w800,
  );

  static const cBodyText1 = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontFamily: fontBody,
    fontWeight: FontWeight.w400,
  );

  static const cSubtitle1 = TextStyle(
    color: text2,
    fontSize: 12,
    fontFamily: fontBody,
    fontWeight: FontWeight.w300,
  );

  /// Theme Data

  static const appBarUnselectedIconTheme = IconThemeData(color: Colors.white);
  static const appBarSelectedIconTheme = IconThemeData(color: blue2);
  static const appBarSelectedItemColor = blue2;
  static const appBarUnselectedItemColor = Colors.white;

  static const textTheme = TextTheme(
    headline2: cHeadline2,
    headline3: cHeadline3,
    headline4: cHeadline4,
    bodyText1: cBodyText1,
    subtitle1: cSubtitle1,
  );

  static final themeData = ThemeData(
    primaryColor: primary,
    accentColor: secondary,
    canvasColor: Colors.redAccent,
    textTheme: textTheme,
  );

  /// FUNCTIONS

  /// Change system ui colors
  static void changeSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primary,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  /// Logo TextStyle
  static Map logoTextStyle(double fontSize) {
    /// for splash screen => 40
    /// for app bar => 22

    TextStyle logoBold = TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      fontFamily: fontHead,
      fontWeight: FontWeight.w800,
    );

    TextStyle logoThin = TextStyle(
      fontSize: fontSize,
      color: Colors.white,
      fontFamily: fontHead,
      fontWeight: FontWeight.w300,
    );

    return {'thin': logoThin, 'bold': logoBold};
  }
}
