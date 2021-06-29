import 'package:flutter/material.dart';
import 'package:pass_app/models/sesion.dart';
import 'package:pass_app/models/usuarios.dart';
import 'package:pass_app/src/reusable_widgets.dart';
import 'package:pass_app/src/validations.dart';
import 'package:pass_app/utils/DataBase.dart';

class Config extends StatefulWidget {
  static const String routeName = "/config";
  @override
  _ConfigState createState() => new _ConfigState();
}

class _ConfigState extends State<Config> {
  final GlobalKey<FormState> formKeyChangeUser = GlobalKey<FormState>();
  TextEditingController passController = TextEditingController();
  TextEditingController keyController = TextEditingController();
  TextEditingController userController = TextEditingController();

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDA44bb), Color(0xff8921aa)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  String _key = Sesion.getKey();
  String _pass = Sesion.getPass();
  String userHint = Sesion.getUsuario();
  String passHint = Sesion.getPass();
  String keyHint = Sesion.getKey();

  @override
  Widget build(BuildContext context) {
    // SHOW DIALOG
    _showDialog() async {
      if (formKeyChangeUser.currentState!.validate() == true) {
        // EVERYTHING OK WE SHOWDIALOG
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Actualizar cuenta"),
                content: Text(
                    "¿Esta seguro de actualizar su cuenta? Si es así guarde sus nuevos credenciales."),
                actions: [
                  TextButton(
                    // Cancel
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    // OKAY
                    onPressed: () {
                      // Usuario nuevo
                      var newDBUSer = Usuarios(
                          usuario: Sesion.getUsuario(), pass: _pass, key: _key);
                      // Usuario antiguo
                      var actualDBUser = Usuarios(
                          usuario: Sesion.getUsuario(),
                          pass: Sesion.getPass(),
                          key: Sesion.getKey());
                      ////////////////////////
                      DBProvider.db
                          .updateUsuario(actualDBUser, newDBUSer); // Actualizar
                      Sesion.changePass(passController.text);
                      Sesion.changeKey(_key);
                      formKeyChangeUser.currentState!.reset();
                      Navigator.pop(context);
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            });
      }
    }

    return new Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getAppBar("Configuración"),
      drawer: ReusableWidgets.getDrawer(context),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 35),
              child: Text(
                'Actualizar',
                style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()..shader = linearGradient),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
              child: Form(
                  key: formKeyChangeUser,
                  child: Column(
                    children: [
                      /////////////////////// Pass
                      TextFormField(
                        controller: passController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            labelText: "Pass actual: " + passHint),
                        validator: (value) {
                          if (Validations.passValidation(value!) < 20)
                            return "No se puede usar una contraseña tan débil.";
                        },
                        onChanged: (value) {
                          _pass = value;
                        },
                      ),
                      /////////////////////// Key
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            flex: 15,
                            child: TextFormField(
                              controller: keyController,
                              keyboardType: TextInputType.name,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Key actual: " + keyHint,
                              ),
                            ),
                          ),
                          Expanded(
                              child: IconButton(
                            onPressed: () {
                              setState(() {
                                keyController.text = Validations.generateKey();
                                _key = keyController.text;
                              });
                            },
                            icon: Icon(Icons.autorenew),
                          ))
                        ],
                      ),
                      /////////////////////// Key
                      Container(
                        margin: EdgeInsets.only(top: 15),
                        child: ReusableWidgets.accesButton("Actualizar usuario",
                            pAccion: () => {_showDialog()}),
                      ),
                    ],
                  )),
            ),
            // ========================== DELETE ACC AND LOG OUT
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter, // We put them at the bottom
                child: Container(
                  margin: EdgeInsets.only(bottom: 45),
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
