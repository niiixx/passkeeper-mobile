import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_app/models/sesion.dart';

import 'package:pass_app/models/usuarios.dart';
import 'package:pass_app/screens/home.dart';
import 'package:pass_app/screens/register_screen.dart';
import 'package:pass_app/src/reusable_widgets.dart';
import 'package:pass_app/utils/DataBase.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> formKeyLogin = GlobalKey<FormState>();
  final GlobalKey<FormState> formPassRetrieve = GlobalKey<FormState>();
  TextEditingController editingController = TextEditingController();

  int index = 0;
  String _user = '';
  String _password = '';
  String _key = "";

  String _userRetrieve = "";
  String _keyRetrieve = "";

  bool visible = true;
  togglePass() {
    // Pass visible or not.
    setState(() {
      visible = !visible;
    });
  }

  String _error = "";
  toggleError(String error) {
    // Toggles error message
    setState(() {
      _error = error;
    });
  }

  logStateForm() async {
    // We clear the logins (maybe logged out/deleted account so they got redirected to log in screen)
    Sesion.restart();
    // Validar inputs
    if (formKeyLogin.currentState!.validate() == true) {
      Future<List<Usuarios>> futureLista = DBProvider.db.getUsers();
      List listaUsuarios = await futureLista;
      // List with all the logins. Later we will search for a match
      for (int i = 0; i < listaUsuarios.length; i++) {
        // We loop the list searching for matches
        if (listaUsuarios[i].getusuario() == _user) {
          toggleError("");
          if (listaUsuarios[i].getpassword() == _password) {
            toggleError("");
            _key = listaUsuarios[i].getkey();
            Sesion.changeUsuario(_user);
            Sesion.changePass(_password);
            Sesion.changeKey(_key);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Home())); // OK - Go home
            formKeyLogin.currentState!.reset();
          } else {
            toggleError("Usuario o contraseña errónea."); // Pass doesnt match
          }
        } else {
          toggleError("Usuario o contraseña errónea."); // User doesnt exist
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //  ========================== DIALOG FOR RETRIEVING PASSWORD
    Future<void> _showDialog() async {
      FocusScope.of(context).unfocus();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              String respuesta;
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                    child: AlertDialog(
                        title: Text("Recuperar contraseña"),
                        actions: [
                          TextButton(
                            // OKAY - Retrieve password
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                        content: Container(
                          child: Form(
                            key: formPassRetrieve,
                            child: Column(
                              children: [
                                /////////////////////// User
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: "Usuario",
                                    hintText: "Usuario",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty == true) {
                                      return "Introduzca un usuario";
                                    }
                                  },
                                  onChanged: (value) => _userRetrieve = value,
                                ),
                                /////////////////////// Key
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: "Key de recuperación",
                                    hintText: "Ej: K@35Af46252Alm1=",
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty == true) {
                                      return "Introduzca una key";
                                    }
                                  },
                                  onChanged: (value) => _keyRetrieve = value,
                                ),
                                /////////////////////// RETRIEVE PASSWORD
                                ReusableWidgets.accesButton(
                                    "Mostrar contraseña",
                                    pAccion: () async => {
                                          if (formPassRetrieve.currentState!
                                                  .validate() ==
                                              true)
                                            {
                                              respuesta = await DBProvider
                                                  .retrievePassword(
                                                      _userRetrieve,
                                                      _keyRetrieve),
                                              editingController.text = respuesta
                                            }
                                        }),
                                /////////////////////// SHOW PASSWORD
                                TextField(
                                  controller: editingController,
                                  readOnly: true,
                                  enableInteractiveSelection: false,
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () {
                                      final data = ClipboardData(
                                          text: editingController.text);
                                      Clipboard.setData(data);
                                    },
                                  )),
                                )
                              ],
                            ),
                          ),
                        ))),
              );
            });
          });
    }

    return new Container(
      margin: EdgeInsets.only(top: 10, bottom: 25, left: 25, right: 25),
      child: (Form(
        key: formKeyLogin,
        child: Column(
          children: [
            /////////////////////// Text if error
            Text(
              _error,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
            ),
            /////////////////////// USER
            TextFormField(
              keyboardType: TextInputType.name,
              decoration:
                  InputDecoration(labelText: "Usuario", hintText: "Usuario"),
              onChanged: (value) => _user = value,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Introduzca un usuario";
                }
              },
            ),
            /////////////////////// PASS
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    flex: 15,
                    child: TextFormField(
                      obscureText: visible,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        hintText: "Contraseña",
                      ),
                      onChanged: (value) => _password = value,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Introduzca una contraseña";
                        }
                      },
                    )),
                Expanded(
                    child: IconButton(
                        onPressed: togglePass,
                        icon: Icon(Icons.remove_red_eye))),
              ],
            ),
            /////////////////////// ACCESS BUTTON
            Container(
              margin: EdgeInsets.only(top: 15),
              child: ReusableWidgets.accesButton("Acceder",
                  pAccion: () => {logStateForm()}),
            ),
            /////////////////////// FORGOT PASS
            Container(
              margin: EdgeInsets.only(top: 15),
              child: InkWell(
                onTap: () {
                  _showDialog();
                },
                child: Text(
                  "¿Has olvidado tu contraseña?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            /////////////////////// GO TO REGISTER BUTTON
            Container(
              margin: EdgeInsets.only(top: 15),
              child: ReusableWidgets.accesButton("No tengo cuenta",
                  pAccion: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterScreen()))
                      }),
            )
          ],
        ),
      )),
    );
  }
}
