import 'package:flutter/material.dart';

import '../constants.dart';

class Logo extends StatelessWidget {
  final double fontSize;

  Logo({@required this.fontSize});

  @override
  Widget build(BuildContext context) {
    Map style = Constants.logoTextStyle(fontSize);

    return RichText(
      text: TextSpan(children: [
        TextSpan(text: 'g', style: style['thin']),
        TextSpan(text: 'Scanner', style: style['bold']),
      ]),
    );
  }
}
