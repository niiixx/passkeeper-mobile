import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_app/models/cuentas.dart';
import 'package:pass_app/models/sesion.dart';
import 'package:pass_app/src/reusable_widgets.dart';
import 'package:pass_app/src/validations.dart';
import 'package:pass_app/utils/DataBase.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => new _HomeState();
}

buildList() {
  // Builds standard list
  var futureLista = DBProvider.db.getCuentas(Sesion.getUsuario());
  Future<List<Cuentas>> listaCuentas = futureLista;
  return listaCuentas;
}

buildFiltreredList(String site) {
  // Builds the list filtrerin the sites
  var futureListaFiltrada =
      DBProvider.db.filtrarCuenta(site, Sesion.getUsuario());
  Future<List<Cuentas>> listaCuentasFiltradas = futureListaFiltrada;
  return listaCuentasFiltradas;
}

buildOrderedList() {
  // Builds the list ordering by name
  var futureListaFiltrada = DBProvider.db.orderCuentas(Sesion.getUsuario());
  Future<List<Cuentas>> listCuentaOrdenadas = futureListaFiltrada;
  return listCuentaOrdenadas;
}

class _HomeState extends State<Home> {
  TextEditingController editingController = TextEditingController();
  final GlobalKey<FormState> formKeyNewAccount = GlobalKey<FormState>();
  final controller = TextEditingController();
  Future<List<Cuentas>> _future = buildList(); // Standard instance

  int i = 0;
  String _user = '';
  String _password = '';
  String _site = '';
  bool ordenado = false;

  void recargarLista() {
    // REloads standard list
    setState(() {
      _future = buildList();
    });
  }

  void ordenarLista() {
    // Orders list
    setState(() {
      if (ordenado == false) {
        // Toggles to build list
        _future = buildOrderedList();
        ordenado = !ordenado;
      } else {
        _future = buildList();
        ordenado = !ordenado;
      }
    });
  }

  void filtrarLista(String value) {
    // Filters list
    setState(() {
      _future =
          buildFiltreredList(value); // Build list only with filtrered results
    });
  }

  @override
  Widget build(BuildContext context) {
    // ========================== DIALOG FOR CREATING NEW ACCOUNTS
    Future<void> _showDialog() async {
      FocusScope.of(context).unfocus();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                    child: AlertDialog(
                        title: Text("Crear cuenta"),
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
                            onPressed: () async {
                              if (formKeyNewAccount.currentState!.validate() ==
                                  true) {
                                var newDBAccount = Cuentas(
                                    owner: Sesion.getUsuario(),
                                    user: _user,
                                    pass: _password,
                                    sitio: _site);
                                DBProvider.db.newAccount(
                                    newDBAccount); // We register the new site
                                formKeyNewAccount.currentState!.reset();
                                recargarLista();
                                Navigator.pop(context);
                              }
                            },
                            child: Text('OK'),
                          ),
                        ],
                        content: Container(
                          child: Form(
                            // Form
                            key: formKeyNewAccount,
                            child: Column(
                              children: [
                                /////////////////////// Site
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: "Página web",
                                    hintText: "Ej: Netflix",
                                  ),
                                  validator: (value) {
                                    if (!Validations.userValidation(value!)) {
                                      return "Nombre de Web demasiado largo";
                                    }
                                  },
                                  onChanged: (value) => _site = value,
                                ),
                                /////////////////////// USER
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: "Nombre de usuario de la cuenta",
                                    hintText: "Usuario",
                                  ),
                                  validator: (value) {
                                    if (!Validations.userValidation(value!)) {
                                      return "Nombre de usuario demasiado largo";
                                    }
                                  },
                                  onChanged: (value) => _user = value,
                                ),
                                /////////////////////// PASS
                                TextFormField(
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: "Contraseña",
                                    hintText: "Contraseña",
                                  ),
                                  validator: (value) {
                                    if (Validations.passValidation(value!) < 20)
                                      return "No se puede usar una contraseña tan débil.";
                                  },
                                  onChanged: (value) => _password = value,
                                ),
                                /////////////////////// RANDOM PASSWORD
                                ReusableWidgets.accesButton(
                                    "Generar contraseña aleatoria",
                                    pAccion: () => {
                                          setState(() {
                                            controller.text =
                                                Validations.generatePass();
                                          })
                                        }),
                                /////////////////////// SHOW RANDOM PASSWORD
                                TextField(
                                  controller: controller,
                                  readOnly: true,
                                  enableInteractiveSelection: false,
                                  decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                    icon: Icon(Icons.copy),
                                    onPressed: () {
                                      final data =
                                          ClipboardData(text: controller.text);
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

    // ========================== LIST OF ACCOUNTS
    Widget listaCuentas(Future<List<Cuentas>> _future) {
      return (FutureBuilder<List<Cuentas>>(
        future: _future, // Pass via argument the accounts we want to show
        // We pass it like that because we want to build the list depending
        // on its standard/filtered/ordered
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ReusableWidgets.row(
                          context, snapshot.data!.elementAt(index),
                          pAccion: () => {recargarLista()});
                    }));
          } else {
            // Snapshot retrieving data
            // Progress indicator
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Cargando",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                CircularProgressIndicator()
              ],
            );
          }
        },
      ));
    }

    // ========================== SCAFFOLD
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: ReusableWidgets.getHomeAppbar(pAccion: () => {_showDialog()}),
      drawer: ReusableWidgets.getDrawer(context),
      body: Container(
        child: Column(
          children: [
            /////////////////////// SEARCH BUTTON
            Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 15),
                child: Row(
                  children: [
                    Flexible(
                      flex: 10,
                      child: TextField(
                        onChanged: (value) {
                          filtrarLista(value);
                        },
                        controller: editingController,
                        decoration: InputDecoration(
                            labelText: "Search",
                            hintText: "Search",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)))),
                      ),
                    ),
                    /////////////////////// SORT BUTTON
                    Flexible(
                      child: IconButton(
                          icon: ordenado
                              ? Icon(Icons.sort)
                              : Icon(Icons.sort_by_alpha),
                          onPressed: () {
                            ordenarLista();
                          }),
                    )
                  ],
                )),
            /////////////////////// DYNAMIC LIST WITH DATABASE ACCOUNTS
            listaCuentas(_future),
          ],
        ),
      ),
    );
  }
}
