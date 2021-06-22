import 'package:flutter/material.dart';
import 'package:pass_app/models/usuarios.dart';
import 'package:pass_app/src/reusable_widgets.dart';
import 'package:pass_app/src/validations.dart';
import 'package:flutter/services.dart';
import 'package:pass_app/utils/DataBase.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => new _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> formKeyRegister = GlobalKey<FormState>();

  String _user = '';
  String _password = '';
  String _recoveryKey = "";
  String _error = "";
  bool visible = true;

  togglePass() {
    // Pass visible or not.
    setState(() {
      visible = !visible;
    });
  }

  toggleError(String error) {
    // Toggles error msg
    setState(() {
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _showDialog() async {
      FocusScope.of(context).unfocus();
      // REGISTER BUTTON FUNCTION
      if (formKeyRegister.currentState!.validate() == true) {
        int validador = await DBProvider.userexists(_user);
        if (validador == 1) toggleError("Usuario ya existe");
        if (validador == 0) {
          toggleError("");
          // EVERYTHING OK WE GENERATE KEY
          _recoveryKey = Validations.generateKey();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  // DIALOG TO SHOW THE KEY
                  title: Text(
                      "Key de recuperación de cuenta. Guardela para recuperar la cuenta en caso de pérdida de contraseña."),
                  content: Text(_recoveryKey,
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  actions: [
                    TextButton(
                      // COPY KEY
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _recoveryKey));
                      },
                      child: Text('Copiar Key al portapapeles'),
                    ),
                    TextButton(
                      // OKAY
                      onPressed: () async {
                        var newDBUSer = Usuarios(
                            usuario: _user, pass: _password, key: _recoveryKey);
                        DBProvider.db.newUser(newDBUSer);
                        formKeyRegister.currentState!.reset();
                        Navigator.pop(context);
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              });
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getAppBar("Registro"),
      body: Container(
        margin: EdgeInsets.only(top: 10, bottom: 25, left: 25, right: 25),
        child: Form(
          key: formKeyRegister,
          child: Column(
            children: [
              /////////////////////// Text if error
              Text(
                _error,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15),
              ),
              /////////////////////// USER
              TextFormField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Nombre de usuario",
                  hintText: "Usuario",
                ),
                validator: (value) {
                  if (!Validations.userValidation(value!)) {
                    return "El nombre de usuario tiene que tener entre 2 y 20 letras.";
                  }
                },
                onChanged: (value) => _user = value,
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
                        validator: (value) {
                          if (Validations.passValidation(value!) < 20)
                            return "No se puede usar una contraseña tan débil.";
                        },
                        onChanged: (value) => _password = value,
                      )),
                  Expanded(
                      child: IconButton(
                          onPressed: togglePass,
                          icon: Icon(Icons.remove_red_eye))),
                ],
              ),
              /////////////////////// CONFIRM PASS
              TextFormField(
                obscureText: visible,
                decoration: InputDecoration(
                  labelText: "Confirmar contraseña",
                  hintText: "Confirmar contraseña",
                ),
                validator: (value) {
                  if (value != _password) return "Las contraseñas no coinciden";
                },
              ),
              /////////////////////// REGISTER BUTTON
              Container(
                margin: EdgeInsets.only(top: 15),
                child: ReusableWidgets.accesButton("Registro",
                    pAccion: () => {_showDialog()}),
              )
            ],
          ),
        ),
      ),
    );
  }
}
