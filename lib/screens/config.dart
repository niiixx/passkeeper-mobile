import 'package:flutter/material.dart';
import 'package:pass_app/src/reusable_widgets.dart';

class Config extends StatefulWidget {
  static const String routeName = "/config";
  @override
  _ConfigState createState() => new _ConfigState();
}

class _ConfigState extends State<Config> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getAppBar("Configuración"),
      drawer: ReusableWidgets.getDrawer(context),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text("hola"),
            // ========================== DELETE ACC AND LOG OUT
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter, // We put them at the bottom
                child: Container(
                  margin: EdgeInsets.only(bottom: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        child: Text(
                          "Cerrar sesión",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        onTap: () {
                          ReusableWidgets.logOut(context);
                        },
                      ),
                      InkWell(
                        child: Text(
                          "Eliminar cuenta",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                        onTap: () {
                          ReusableWidgets.deleteAccount(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
