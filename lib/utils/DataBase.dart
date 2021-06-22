import 'dart:io';

import 'package:pass_app/models/cuentas.dart';
import 'package:pass_app/models/sesion.dart';
import 'package:pass_app/models/usuarios.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  static final DBProvider db = DBProvider._();
  DBProvider._();

  static Database? _database;
  Future<Database> get database async => _database ??= await initDB();

  /* 
  The ??= operator will check if _database is null and set it to the value of 
  await initDB() if that is the case and then return the new 
  value of _database. If _database already has a value, it will just be returned.
  */

  initDB() async {
    Directory dataDirectory = await getApplicationDocumentsDirectory();
    String dbpath = join(dataDirectory.path, "database.db");
    //await deleteDatabase(dbpath); // Reiniciar database
    //print dbpath
    return await openDatabase(
      dbpath,
      onCreate: (db, version) async {
        await db.execute('''
        create table usuarios(usuario varchar(45) NOT NULL, pass varchar(45) NOT NULL, key varchar(45))
        '''); // Table where the users get stored
        await db.execute('''
        create table cuentas(owner varchar(45) NOT NULL, sitio varchar(45) NOT NULL, usuario varchar(45) NOT NULL, 
        pass varchar(174) NOT NULL)
        '''); // Table where the site accounts get stored
      },
      version: 1,
    );
  }

  newUser(Usuarios newUser) async {
    final db = await database;

    await db.insert("usuarios", newUser.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  newAccount(Cuentas newAccount) async {
    final db = await database;

    await db.insert("cuentas", newAccount.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Usuarios>> getUsers() async {
    final db = await database;

    // Search usuarios table
    final List<Map<String, dynamic>> maps = await db.query('usuarios');

    // Convert the List<Map<String, dynamic> into a List<Usuarios>.
    return List.generate(maps.length, (i) {
      return Usuarios(
          usuario: maps[i]['usuario'],
          pass: maps[i]['pass'],
          key: maps[i]['key']);
    });
  }

  static Future<int> userexists(String user) async {
    Future<List<Usuarios>> futureLista = DBProvider.db.getUsers();
    List listaUsuarios = await futureLista;
    for (int i = 0; i < listaUsuarios.length; i++) {
      if (listaUsuarios[i].getusuario() == user) {
        return 1; // User exists already
      }
    }
    return 0; // OK
  }

  static Future<String> retrievePassword(String user, String key) async {
    Future<List<Usuarios>> futureLista = DBProvider.db.getUsers();
    List listaUsuarios = await futureLista;
    for (int i = 0; i < listaUsuarios.length; i++) {
      if (listaUsuarios[i].getusuario() == user) {
        if (listaUsuarios[i].getkey() == key) {
          return listaUsuarios[i].getpassword();
        }
      }
    }
    return "Contraseña no encontrada"; // OK
  }

  Future<List<Cuentas>> getCuentas(String owner) async {
    final db = await database;

    // Search cuentas table
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * from cuentas where owner = ?', [owner]);
    // Convert the List<Map<String, dynamic> into a List<Cuentas>.
    return List.generate(maps.length, (i) {
      return Cuentas(
        owner: maps[i]['owner'],
        sitio: maps[i]['sitio'],
        user: maps[i]['usuario'],
        pass: maps[i]['pass'],
      );
    });
  }

  Future<List<Cuentas>> orderCuentas(String owner) async {
    final db = await database;

    // Search cuentas table
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * from cuentas where owner = ? order by sitio', [owner]);
    // Convert the List<Map<String, dynamic> into a List<Cuentas>.
    return List.generate(maps.length, (i) {
      return Cuentas(
        owner: maps[i]['owner'],
        sitio: maps[i]['sitio'],
        user: maps[i]['usuario'],
        pass: maps[i]['pass'],
      );
    });
  }

  Future<List<Cuentas>> filtrarCuenta(String site, String owner) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "Select * from cuentas where sitio like ? and owner = ?",
        ["$site%", owner]);
    // Convert the List<Map<String, dynamic> into a List<Cuentas>.
    return List.generate(maps.length, (i) {
      return Cuentas(
        owner: maps[i]['owner'],
        sitio: maps[i]['sitio'],
        user: maps[i]['usuario'],
        pass: maps[i]['pass'],
      );
    });
  }

  Future<void> deleteCuenta(Cuentas cuentaEliminar) async {
    // Eliminar cuenta
    final db = await database;
    String owner = cuentaEliminar.getowner();
    String sitio = cuentaEliminar.getsitio();
    String pass = cuentaEliminar.getpass();
    String user = cuentaEliminar.getuser();
    await db.delete("cuentas",
        where: 'owner = ? and sitio = ? and pass = ? and usuario = ?',
        whereArgs: [owner, sitio, pass, user]);
  }

  Future<void> updateCuenta(Cuentas cuentaAntigua, Cuentas cuentaNueva) async {
    // Update cuenta
    final db = await database;
    await db.rawQuery(
        'update cuentas SET owner = ?, sitio = ?, pass = ?, usuario = ? where owner = ? and sitio = ? and pass = ? and usuario = ?',
        [
          cuentaNueva.getowner(),
          cuentaNueva.getsitio(),
          cuentaNueva.getpass(),
          cuentaNueva.getuser(),
          cuentaAntigua.getowner(),
          cuentaAntigua.getsitio(),
          cuentaAntigua.getpass(),
          cuentaAntigua.getuser()
        ]);
  }

  Future<void> deleteUser() async {
    // Eliminar usuarifer
    final db = await database;

    String usuario = Sesion.getUsuario();
    String pass = Sesion.getPass();
    await db.delete("usuarios",
        where: 'usuario = ? and pass = ?', whereArgs: [usuario, pass]);
  }
}
