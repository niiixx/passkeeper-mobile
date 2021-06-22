import 'package:flutter/material.dart';
import 'package:pass_app/screens/login_screen.dart';
import 'package:pass_app/src/reusable_widgets.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ReusableWidgets.getAppBar("Iniciar Sesión"),
        body: LoginScreen(),
        //drawer: ReusableWidgets.getDrawer(context),
      ),
    );
  }
}
