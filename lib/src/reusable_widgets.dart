import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_app/app.dart';
import 'package:pass_app/models/cuentas.dart';
import 'package:pass_app/models/sesion.dart';
import 'package:pass_app/screens/config.dart';
import 'package:pass_app/screens/home.dart';
import 'package:pass_app/utils/DataBase.dart';

class ReusableWidgets {
  /* =================== APP BAR =================== */
  static getAppBar(String title) {
    return PreferredSize(
        preferredSize: Size.fromHeight(47.0),
        child: AppBar(
          title: Text(title, style: TextStyle(fontSize: 25)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
        ));
  }

  static getHomeAppbar({required Function pAccion}) {
    return PreferredSize(
        preferredSize: Size.fromHeight(45.0),
        child: AppBar(
          title: Text("Tus cuentas", style: TextStyle(fontSize: 25)),
          centerTitle: true,
          backgroundColor: Colors.lightBlue,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    pAccion();
                  },
                  iconSize: 30,
                )),
          ],
        ));
  }

  /* =================== BUTTONS =================== */

  static Widget accesButton(String texto, {required Function pAccion}) {
    return Container(
      margin: EdgeInsets.only(top: 20, bottom: 20),
      child: ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 250, height: 50),
          child: TextButton(
              onPressed: () {
                pAccion();
              },
              child: Text(texto),
              style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(247, 239, 237, 1),
                  onPrimary: Colors.black,
                  onSurface: Color.fromRGBO(222, 210, 207, 1),
                  animationDuration: Duration(seconds: 2)))),
    );
  }

  /* =================== DRAWERS =================== */

  static Drawer getDrawer(BuildContext context) {
    // Visibile drawer
    var header = Container(
        margin: EdgeInsets.only(bottom: 23, top: 35),
        child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: ClipOval(child: Image.asset("assets/images/user.png"))));
    ListTile getItem(Icon icon, String dec, MaterialPageRoute route) {
      return ListTile(
        // Scheme that the items will follow
        leading: icon,
        title: Text(dec, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          Navigator.pushReplacement(context, route);
        },
      );
    }

    ListView getList() {
      // List of the drawer items with their routes
      return ListView(
        children: [
          header,
          Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 27),
              child: Text(
                "Bienvenido, " + Sesion.getUsuario(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          getItem(Icon(Icons.settings), "Configuración",
              MaterialPageRoute(builder: (context) => Config())),
          Divider(color: Colors.black),
          getItem(Icon(Icons.home), "Página principal",
              MaterialPageRoute(builder: (context) => Home())),
          Divider(color: Colors.black),
          AboutListTile(
            // About is a popup, so its kinda different to the others
            child: Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
            applicationIcon: Icon(Icons.favorite),
            applicationVersion: "v1.0.0",
            icon: Icon(Icons.info),
          )
        ],
      );
    }

    return Drawer(
        child: Container(
            color: Colors.yellowAccent, child: getList())); // Returned drawer
  }

  /* =================== LIST ROW ACCOUNTS =================== */

  static ListTile row(BuildContext context, Cuentas cuenta,
      {required Function pAccion}) {
    return ListTile(
        isThreeLine: true,
        trailing: Wrap(children: [
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                updateSite(context, cuenta, pAccion: (pAccion));
              }),
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteSite(context, cuenta, pAccion: (pAccion));
              }),
        ]),
        leading: ReusableWidgets.sitePic(cuenta.sitio),
        title: Text(cuenta.sitio),
        onTap: () {
          showSite(context, cuenta);
        },
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Usuario: " + cuenta.user),
            Text("Contraseña: " + cuenta.pass)
          ],
        ));
  }

  /* =================== SHOW SITE =================== */

  static Widget showSite(BuildContext context, Cuentas cuenta) {
    final GlobalKey<FormState> formKeyShowSite = GlobalKey<FormState>();
    TextEditingController siteController = TextEditingController();
    TextEditingController passController = TextEditingController();
    TextEditingController userController = TextEditingController();
    siteController.text = cuenta.sitio;
    passController.text = cuenta.pass;
    userController.text = cuenta.user;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: AlertDialog(
                actions: [
                  TextButton(
                    // GO OUT
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
                content: Container(
                  child: Form(
                    // Form
                    key: formKeyShowSite,
                    child: Column(
                      children: [
                        ReusableWidgets.sitePic(cuenta.sitio),
                        /////////////////////// Site
                        TextFormField(
                          controller: siteController,
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: "Página web",
                          ),
                        ),
                        /////////////////////// USer
                        TextFormField(
                          controller: userController,
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: "Usuario",
                          ),
                        ),
                        /////////////////////// Pass
                        TextFormField(
                          controller: passController,
                          keyboardType: TextInputType.name,
                          readOnly: true,
                          enableInteractiveSelection: false,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                          ),
                        ),
                        accesButton("Copiar datos", pAccion: () {
                          String copiarSite = "Site: " + cuenta.sitio;
                          String copiarUsuario = "\nUsuario: " + cuenta.user;
                          String copiarPass = "\nPass: " + cuenta.pass;
                          final data = ClipboardData(
                              text: "$copiarSite" +
                                  "$copiarUsuario" +
                                  "$copiarPass");
                          Clipboard.setData(data);
                        })
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
    return Container();
  }

  /* =================== UPDATE SITE =================== */

  static Widget updateSite(BuildContext context, Cuentas cuenta,
      {required Function pAccion}) {
    final GlobalKey<FormState> formUpdateSite = GlobalKey<FormState>();
    TextEditingController userController = TextEditingController();
    TextEditingController passController = TextEditingController();
    TextEditingController siteController = TextEditingController();

    siteController.text = cuenta.getsitio();
    userController.text = cuenta.getuser();
    passController.text = cuenta.getpass();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                  child: AlertDialog(
                title: Text("Editar cuenta"),
                content: Form(
                  key: formUpdateSite,
                  child: Column(
                    children: [
                      /////////////////////// Site
                      TextFormField(
                        controller: siteController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Sitio",
                        ),
                        validator: (value) {
                          if (value!.isEmpty == true) {
                            return "Introduzca una web";
                          }
                        },
                      ),
                      /////////////////////// User
                      TextFormField(
                        controller: userController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Usuario",
                        ),
                        validator: (value) {
                          if (value!.isEmpty == true) {
                            return "Introduzca un usuario";
                          }
                        },
                      ),
                      /////////////////////// Password
                      TextFormField(
                        controller: passController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Pass",
                        ),
                        validator: (value) {
                          if (value!.isEmpty == true) {
                            return "Introduzca una pass";
                          }
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    // GO OUT
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    // OKAY - Update account
                    onPressed: () {
                      {
                        var newDBAcc = Cuentas(
                            owner: cuenta.getowner(),
                            user: userController.text,
                            pass: passController.text,
                            sitio: siteController.text);
                        DBProvider.db.updateCuenta(cuenta, newDBAcc);
                        pAccion();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('OK'),
                  ),
                ],
              )));
        });
    return Container();
  }

  /* =================== DELETE SITE =================== */

  static Widget deleteSite(BuildContext context, Cuentas cuenta,
      {required Function pAccion}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: AlertDialog(
            title: Text("¿Estas seguro de querer eliminar la cuenta?"),
            content:
                Text("Al eliminar la cuenta no podrás volverla a recuperar."),
            actions: [
              TextButton(
                // GO OUT
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                // OKAY - Register account
                onPressed: () {
                  {
                    DBProvider.db.deleteCuenta(cuenta);
                    pAccion();
                    Navigator.pop(context);
                  }
                },
                child: Text('OK'),
              ),
            ],
          ));
        });
    return Container();
  }

  /* =================== DELETE ACCOUNT =================== */

  static Widget deleteAccount(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: AlertDialog(
            title: Text("¿Estas seguro de borrar su cuenta?"),
            content: Text(
                "Al eliminar su cuenta pederá todas las contraseñas guardadas."),
            actions: [
              TextButton(
                // GO OUT
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                // OKAY - Register account
                onPressed: () {
                  {
                    DBProvider.db.deleteUser();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  }
                },
                child: Text('OK'),
              ),
            ],
          ));
        });
    return Container();
  }

  /* =================== LOG OUT =================== */

  static Widget logOut(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
              child: AlertDialog(
            title: Text("¿Estas seguro de cerrar sesión?"),
            content: Text(
                "Tus contraseñas se guardarán pero tendrás que volver a iniciar sesión para acceder a ellas."),
            actions: [
              TextButton(
                // GO OUT
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                // OKAY - Register account
                onPressed: () {
                  {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => MyApp()));
                  }
                },
                child: Text('OK'),
              ),
            ],
          ));
        });
    return Container();
  }

  /* =================== SITES PICS LIST =================== */

  static Widget sitePic(String nombreSitio) {
    if (nombreSitio.toLowerCase().contains("google")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/google.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("netflix")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/netflix.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("twitter")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/twitter.png")));
    }
    if (nombreSitio.toLowerCase().contains("facebook")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/facebook.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("linkedin")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/linkedin.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("youtube")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/youtube.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("twitch")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/twitch.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("spotify")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/spotify.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("gmail") ||
        nombreSitio.toLowerCase().contains("email") ||
        nombreSitio.toLowerCase().contains("mail") ||
        nombreSitio.toLowerCase().contains("e-mail")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/gmail.jpg")));
    }
    if (nombreSitio.toLowerCase().contains("steam")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/steam.png")));
    }
    if (nombreSitio.toLowerCase().contains("discord")) {
      return CircleAvatar(
          radius: 23,
          child: ClipOval(child: Image.asset("assets/images/discord.jpg")));
    }
    return CircleAvatar(
      radius: 23,
      child: Text(nombreSitio[0].toUpperCase()),
    );
  }
}
