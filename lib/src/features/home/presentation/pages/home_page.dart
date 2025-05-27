import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlutterLogo(),
          FlutterLogo(),
          FlutterLogo(),
          FlutterLogo(),
          FlutterLogo(),
          FlutterLogo(),
        ],
      ),
    );
  }
}
