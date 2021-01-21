import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 250,
        width: 250,
        child: CircularProgressIndicator(backgroundColor: Colors.purple),
      );
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: Center(child: Loader()),
      );
}
